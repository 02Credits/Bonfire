using Lidgren.Network;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NetworkingLibrary
{
    public class ServiceSubscription<S>
    {
        public ServiceConnection ServiceConnection { get; set; }
        public ConnectionInformation ConnectionInformation { get; set; }
        public S Service { get; set; }

        public ServiceSubscription(ServiceConnection serviceConnection, S service)
        {
            ServiceConnection = serviceConnection;
            ConnectionInformation = new ConnectionInformation(
                    serviceConnection.Connection.RemoteEndPoint.Address.ToString(),
                    serviceConnection.Connection.RemoteEndPoint.Port
                );
            Service = service;
        }
    }
}
