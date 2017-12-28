using Lidgren.Network;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NetworkingLibrary
{
    public abstract class Service
    {
        public ServiceConnection CallingConnection { get; set; }

        public ConnectionInformation CallingConnectionInformation { get; set; }

        public ServiceManager NetworkManager { get; set; }

        public abstract string GetServiceName();

        public virtual void ConnectionDisconnected(ServiceConnection connection) { }
    }
}
