using Castle.DynamicProxy;
using Lidgren.Network;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Configuration;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace NetworkingLibrary
{
    public class ServiceManager
    {
        public NetPeer LidgrenPeer { get; set; }
        public List<string> PublishedServices
        {
            get
            {
                return serviceExecutors.Keys.ToList();
            }
        }

        private IdManager AckIDManager = new IdManager();
        private IdManager ConvoIDManager = new IdManager();

        private Dictionary<NetConnection, ServiceConnection> serviceConnections = new Dictionary<NetConnection, ServiceConnection>(); 

        private ConcurrentQueue<NetIncomingMessage> messages = new ConcurrentQueue<NetIncomingMessage>();
        private Dictionary<long, Action<bool, NetIncomingMessage>> conversationSubscriptions = new Dictionary<long,Action<bool, NetIncomingMessage>>();

        private Dictionary<string, PublishedServiceExecutor> serviceExecutors = new Dictionary<string, PublishedServiceExecutor>();

        private ProxyGenerator proxyGenerator = new ProxyGenerator();

        public ServiceManager(string identifier, int port)
        {
            var config = new NetPeerConfiguration(identifier) {Port = port, AcceptIncomingConnections = true, };
            config.EnableMessageType(NetIncomingMessageType.NatIntroductionSuccess);
            config.EnableMessageType(NetIncomingMessageType.ConnectionApproval);
            LidgrenPeer = new NetPeer(config);
            LidgrenPeer.Start();

            PublishDynamicService(new PublishedServices(this));

            Task.Run(() =>
            {
                while (true)
                {
                    if (LidgrenPeer != null)
                    {
                        NetIncomingMessage msg = LidgrenPeer.ReadMessage();
                        if (msg != null)
                        {
                            messages.Enqueue(msg);
                            continue;
                        }
                        Thread.Sleep(20);
                    }
                }
            });
        }

        public virtual void Update()
        {
            NetIncomingMessage msg;
            while (messages.TryDequeue(out msg))
            {
                switch (msg.MessageType)
                {
                    case NetIncomingMessageType.Data:
                        var ackId = msg.ReadInt64();
                        ParseOrHandleAck(msg, ackId);
                        break;
                    case NetIncomingMessageType.StatusChanged:
                        HandleStatusChanged(msg);
                        break;
                    case NetIncomingMessageType.DebugMessage:
                        Console.WriteLine(msg.ReadString());
                        break;
                    case NetIncomingMessageType.ConnectionApproval:
                        Console.WriteLine("ServiceConnection approved.");
                        msg.SenderConnection.Approve();
                        break;
                    default:
                        Console.WriteLine("Unhandled type: " + msg.MessageType);
                        break;
                }
                LidgrenPeer.Recycle(msg);
            }

            var now = DateTime.Now;
            foreach (var serviceConnection in serviceConnections.Values)
            {
                if (serviceConnection.Connected)
                {
                    serviceConnection.LastSeen = now;
                    Action<bool> sendCommandAction;
                    while (serviceConnection.UnsentCommands.TryTake(out sendCommandAction))
                    {
                        sendCommandAction(false);
                    }
                }
                else if ((now - serviceConnection.LastSeen).TotalSeconds > 10)
                {
                    Action<bool> sendCommandAction;
                    while (serviceConnection.UnsentCommands.TryTake(out sendCommandAction))
                    {
                        sendCommandAction(true);
                    }
                }
            }

            ResendMessages();
        }

        private void HandleStatusChanged(NetIncomingMessage msg)
        {
            var status = (NetConnectionStatus) msg.ReadByte();
            if (status == NetConnectionStatus.Disconnected)
            {
                Console.WriteLine("ServiceConnection disconnected:" + msg.SenderConnection.RemoteEndPoint.Address);
                foreach (var serviceExecutor in serviceExecutors.Values)
                {
                    serviceExecutor.ServiceObject.ConnectionDisconnected(serviceConnections[msg.SenderConnection]);
                }
                serviceConnections.Remove(msg.SenderConnection);
            }
            else if (status == NetConnectionStatus.Connected || status == NetConnectionStatus.InitiatedConnect)
            {
                Console.WriteLine("ServiceConnection Connected:" + msg.SenderConnection.RemoteEndPoint.Address);
                if (!serviceConnections.ContainsKey(msg.SenderConnection))
                {
                    serviceConnections[msg.SenderConnection] = new ServiceConnection(msg.SenderConnection);
                }
            }
        }

        public void PublishDynamicService(Service serviceObject)
        {
            PublishService(new DynamicPublishedServiceExecutor(this, serviceObject));
        }

        public void PublishService(PublishedServiceExecutor executor)
        {
            executor.ServiceObject.NetworkManager = this;
            serviceExecutors[executor.ServiceObject.GetServiceName()] = executor;
            Console.WriteLine("Service " + executor.ServiceObject.GetServiceName() + " published.");
        }

        public ServiceSubscription<R> SubscribeToService<R>(string serviceName, ConnectionInformation connectionInfo)
            where R : class
        {
            var ipEndpoint = new IPEndPoint(NetUtility.Resolve(connectionInfo.Address), connectionInfo.Port);
            var connection = LidgrenPeer.GetConnection(ipEndpoint);
            if (connection == null)
            {
                connection = LidgrenPeer.Connect(ipEndpoint);
                serviceConnections[connection] = new ServiceConnection(connection);
            }

            return SubscribeToService<R>(serviceName, serviceConnections[connection]);
        }

        public ServiceSubscription<R> SubscribeToService<R>(string serviceName, ServiceConnection serviceConnection)
            where R : class
        {
            return new ServiceSubscription<R>(
                serviceConnection,
                (R)(proxyGenerator.CreateInterfaceProxyWithoutTarget(typeof(R), new ServiceInterceptor(this, serviceName, serviceConnection))));
        }

        void ParseOrHandleAck(NetIncomingMessage msg, long ackId)
        {
            var connection = serviceConnections[msg.SenderConnection];
            var serviceName = msg.ReadString();
            if (serviceName == "ack")
            {
                Console.WriteLine("Ack recieved for message ackID:" + ackId);
                connection.NonAckedMessages.Remove(ackId);
            }
            else
            {
                // Send Acknowledgment

                // skip if we have already seen this message
                if (!connection.SeenAckIds.Contains(ackId))
                {
                    connection.SeenAckIds.Add(ackId);
                    var convoId = msg.ReadInt64();
                    if (serviceName == "response")
                    {
                        SendAck(msg, ackId);

                        // this must be the return value of a call from me to a service
                        if (conversationSubscriptions.ContainsKey(convoId))
                        {
                            conversationSubscriptions[convoId](false, msg);
                            conversationSubscriptions.Remove(convoId);
                        }
                    }
                    else
                    {
                        // this must be a call from someone to one of my published services
                        var data = ParseMessage(serviceName, msg);
                        if (data != null)
                        {
                            SendAck(msg, ackId);

                            var tuple = GetAckedMessage(connection);
                            var responseMessage = tuple.Item1;
                            var newAck = tuple.Item2;
                            responseMessage.Write("response");
                            responseMessage.Write(convoId);
                            responseMessage.Write(data.Length);
                            responseMessage.Write(data);
                            connection.NonAckedMessages[newAck] = new OutgoingMessage(DateTime.Now, responseMessage.PeekDataBuffer());
                            var result = LidgrenPeer.SendMessage(responseMessage, msg.SenderConnection,
                                NetDeliveryMethod.Unreliable);
                            if (result != NetSendResult.Sent)
                            {
                                Console.WriteLine("Something went horribly wrong");
                            }
                        }
                        else
                        {
                            // NOTE SHOULD SEND A MESSAGE BACK WHICH WILL THROW AN ERROR.
                            Console.WriteLine("Unrecognized Message...");
                        }
                    }
                }
            }
        }

        void SendAck(NetIncomingMessage msg, long ackId)
        {
            var ackMessage = LidgrenPeer.CreateMessage();
            ackMessage.Write(ackId);
            ackMessage.Write("ack");
            LidgrenPeer.SendMessage(ackMessage, msg.SenderConnection, NetDeliveryMethod.Unreliable);
        }

        private Tuple<NetOutgoingMessage, long> GetAckedMessage(ServiceConnection connection)
        {
            var msg = LidgrenPeer.CreateMessage();
            var ackId = AckIDManager.GetNextId();
            msg.Write(ackId);
            return Tuple.Create(msg, ackId);
        }

        private byte[] ParseMessage(string serviceName, NetIncomingMessage msg)
        {
            PublishedServiceExecutor executor;
            if (serviceExecutors.TryGetValue(serviceName, out executor))
            {
                return executor.ExecuteMessage(msg, serviceConnections[msg.SenderConnection]);
            }
            else
            {
                // NOTE SHOULD SEND A MESSAGE BACK WHICH WILL THROW AN ERROR.
                return null;
            }
        }

        private void ResendMessages()
        {
            var currentTime = DateTime.Now;
            foreach (var connection in serviceConnections.Values)
            {
                foreach (var id in connection.NonAckedMessages.Keys.ToList())
                {
                    var outgoingMessage = connection.NonAckedMessages[id];
                    if ((currentTime - outgoingMessage.TimeOriginallySent).TotalSeconds < 10)
                    {
                        if ((currentTime - outgoingMessage.TimeSinceLastResent).TotalSeconds > 1)
                        {
                            if (outgoingMessage.Data.Length != 0)
                            {
                                Console.WriteLine("  message because ack not received");
                                var ackMessage = LidgrenPeer.CreateMessage();
                                ackMessage.Write(outgoingMessage.Data);
                                LidgrenPeer.SendMessage(ackMessage, connection.Connection, NetDeliveryMethod.Unreliable);
                                outgoingMessage.TimeSinceLastResent = DateTime.Now;
                            }
                            // Not sure this is needed here...
                            else
                            {
                                connection.NonAckedMessages.Remove(id);
                            }
                        }
                    }
                    else
                    {
                        if (conversationSubscriptions.ContainsKey(id))
                        {
                            conversationSubscriptions[id](true, null);
                            conversationSubscriptions.Remove(id);
                            connection.NonAckedMessages.Remove(id);
                        }
                    }
                }
            }
        }

        public Task<R> SendCommand<R>(string serviceName, ServiceConnection serviceConnection, string methodName, List<object> parameters)
        {
            var completionSource = new TaskCompletionSource<R>();
            Action<bool> sendCommandAction = (exception) =>
                {
                    if (exception)
                    {
                        completionSource.SetException(new TransmitionFailedException());
                    }
                    else
                    {
                        var tuple = GetAckedMessage(serviceConnection);
                        var msg = tuple.Item1;
                        var ackId = tuple.Item2;
                        msg.Write(serviceName);
                        var id = ConvoIDManager.GetNextId();
                        msg.Write(id);
                        msg.Write(methodName);

                        foreach (var parameter in parameters)
                        {
                            var data = SerializationHelper.SerializeObject(parameter);
                            msg.Write(data.Length);
                            msg.Write(data);
                        }

                        conversationSubscriptions[id] = (transmitionException, responseMessage) =>
                        {
                            if (!transmitionException)
                            {
                                var dataLength = responseMessage.ReadInt32();
                                if (dataLength > 0)
                                {
                                    var data = responseMessage.ReadBytes(dataLength);
                                    var obj = SerializationHelper.Deserialize<R>(data);
                                    completionSource.SetResult(obj);
                                }
                                else
                                {
                                    completionSource.SetResult(default(R));
                                }
                            }
                            else
                            {
                                completionSource.SetException(new TransmitionFailedException());
                            }
                        };

                        serviceConnection.NonAckedMessages[ackId] = new OutgoingMessage(DateTime.Now, msg.PeekDataBuffer());
                        LidgrenPeer.SendMessage(msg, serviceConnection.Connection, NetDeliveryMethod.Unreliable);
                    }
                };
            serviceConnection.UnsentCommands.Add(sendCommandAction);
            return completionSource.Task;
        }
    }
}
