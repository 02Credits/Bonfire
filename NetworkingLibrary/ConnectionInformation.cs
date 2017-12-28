using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using ProtoBuf;

namespace NetworkingLibrary
{
    [ProtoContract]
    public class ConnectionInformation
    {
        [ProtoMember(1)] public string Address;
        [ProtoMember(2)] public int Port;

        public ConnectionInformation(string address, int port)
        {
            Address = address;
            Port = port;
        }

        public ConnectionInformation(IPEndPoint ipEndPoint)
        {
            Address = ipEndPoint.Address.ToString();
            Port = ipEndPoint.Port;
        }

        public IPEndPoint GetIPEndPoint()
        {
            var ipAddresses = Dns.GetHostAddresses(Address);
            return new IPEndPoint(ipAddresses[0], Port);
        }
    }
}
