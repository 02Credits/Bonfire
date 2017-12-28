using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Lidgren.Network;
using System.Collections.Concurrent;

namespace NetworkingLibrary
{
    public class ServiceConnection
    {
        public bool Connected
        {
            get { return Connection.Status == NetConnectionStatus.Connected; }
        }
        public NetConnection Connection { get; set; }
        public Dictionary<long, OutgoingMessage> NonAckedMessages { get; set; }
        public HashSet<long> SeenAckIds { get; set; }
        public ConcurrentBag<Action<bool>> UnsentCommands { get; set; }
        public DateTime LastSeen { get; set; }

        public ServiceConnection(NetConnection connection)
        {
            Connection = connection;
            NonAckedMessages = new Dictionary<long, OutgoingMessage>();
            SeenAckIds = new HashSet<long>();
            UnsentCommands = new ConcurrentBag<Action<bool>>();
            LastSeen = DateTime.Now;
        }
    }
}
