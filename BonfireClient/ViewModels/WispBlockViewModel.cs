using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using BonfireClient.Events;
using Caliburn.Micro;

namespace BonfireClient.ViewModels
{
    public class WispBlockViewModel : PropertyChangedBase, IHandle<ProfileChangedEvent>
    {
        public Guid UserId { get; set; }
        public BindableCollection<WispViewModel> Wisps { get; set; }
        public UserProfile Profile { get; set; }

        public DateTime EarliestTime { get; set; }

        public ImageSource ImageSource
        {
            get { return Profile.ImageSource; }
        }

        public string UserName
        {
            get { return Profile.UserName; }
        }

        public WispBlockViewModel(IEventAggregator eventAggregator, ProfileManager profileManager, Guid userId)
        {
            UserId = userId;
            Wisps = new BindableCollection<WispViewModel>();
            Profile = profileManager.Users[userId];

            eventAggregator.Subscribe(this);
        }

        public void AddWisp(WispViewModel wispViewModel)
        {
            var time = wispViewModel.Wisp.TimeCreated;
            if (Wisps.Count == 0)
            {
                EarliestTime = time;
            }
            else
            {
                if (time < EarliestTime)
                {
                    EarliestTime = time;
                }
            }

            for (int i = 0; i < Wisps.Count; i++)
            {
                if (Wisps[i].Wisp.TimeCreated > wispViewModel.Wisp.TimeCreated)
                {
                    Wisps.Insert(i, wispViewModel);
                    return;
                }   
            }
            Wisps.Add(wispViewModel);
        }

        public void Handle(ProfileChangedEvent e)
        {
            if (e.UserId == UserId)
            {
                NotifyOfPropertyChange(() => ImageSource);
                NotifyOfPropertyChange(() => UserName);
            }
        }
    }
}
