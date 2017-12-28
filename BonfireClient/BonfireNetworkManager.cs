using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Threading;
using BonfireClient.Services;
using Caliburn.Micro;
using NetworkingLibrary;
using Ninject;

namespace BonfireClient
{
    public class BonfireNetworkManager
    {
        IKernel kernel;
        bool hosting = false;
        ServiceManager manager;

        public BonfireNetworkManager(IKernel kernel)
        {
            this.kernel = kernel;

            manager = new ServiceManager("Bonfire", 54448);

            var timer = new DispatcherTimer {Interval = new TimeSpan(0, 0, 0, 0, 13)};
            timer.Tick += timer_Tick;
            timer.Start();
        }

        void timer_Tick(object sender, EventArgs e)
        {
            manager.Update();
        }

        public bool HostGroup()
        {
            if (!hosting)
            {
                manager.PublishDynamicService(kernel.Get<GroupLeaderService>());
                hosting = true;
                return true;
            }
            return false;
        }

        public ServiceSubscription<IGroupLeaderService> ConnectToGroupLeader()
        {
            manager.PublishDynamicService(kernel.Get<BonfirePeerService>());
            return manager.SubscribeToService<IGroupLeaderService>(
                "GroupLeaderService", 
                new ConnectionInformation("the-simmons.dnsalias.net", 54448));
        }
    }
}
