using Lidgren.Network;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NetworkingLibrary
{
    public abstract class PublishedServiceExecutor
    {
        public abstract Dictionary<string, Func<NetIncomingMessage, byte[]>> Parsers { get; }
        public ServiceManager Manager { get; private set; }
        public Service ServiceObject { get; private set; }

        public PublishedServiceExecutor(ServiceManager manager, Service serviceObject)
        {
            Manager = manager;
            ServiceObject = serviceObject;
        }

        public byte[] ExecuteMessage(NetIncomingMessage msg, ServiceConnection serviceConnection)
        {
            ServiceObject.CallingConnection = serviceConnection;
            ServiceObject.CallingConnectionInformation = 
                new ConnectionInformation(
                    msg.SenderConnection.RemoteEndPoint.Address.ToString(), 
                    msg.SenderConnection.RemoteEndPoint.Port);
            var methodName = msg.ReadString();
            return Parsers[methodName](msg);
        }
    }
}
