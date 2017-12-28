using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NetworkingLibrary
{
    public class PublishedServices : Service
    {
        ServiceManager networkManager;
        public PublishedServices(ServiceManager manager)
        {
            networkManager = manager;
        }

        public List<string> GetPublishedServices()
        {
            return networkManager.PublishedServices;
        }

        public override string GetServiceName()
        {
            return "PublishedServices";
        }
    }
}
