using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Threading;
using NetworkingLibrary;
using BonfireNetworking.Services;

namespace BonfireNetworking
{
    public class BonfireNetworkManager
    {
        bool hosting = false;
        ServiceManager manager;
        public BonfireNetworkManager()
        {
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
                manager.PublishDynamicService(new GroupLeaderService());
                hosting = true;
                return true;
            }
            return false;
        }

        public ServiceSubscription<IGroupLeaderService> JoinGroup(IWispReciever wispReciever)
        {
            manager.PublishDynamicService(new BonfirePeerService(wispReciever.RecieveWisp));
            return manager.SubscribeToService<IGroupLeaderService>(
                "GroupLeaderService", 
                new ConnectionInformation("the-simmons.dnsalias.net", 54448));
        }
    }
}
