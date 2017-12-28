using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Controls;
using System.Windows.Input;
using BonfireClient.Events;
using BonfireClient.Model;
using BonfireClient.Services;
using BonfireClient.Views;
using Caliburn.Micro;
using NetworkingLibrary;
using Ninject;
using Ninject.Parameters;

namespace BonfireClient.ViewModels
{
    public class GroupShellViewModel : GroupShellBase, IHandle<Wisp>
    {
        IKernel kernel;

        BonfireNetworkManager networkManager;
        StorageManager storageManager;
        ProfileManager profileManager;
        GroupShellView groupShellView;

        bool autoStuck = true;

        public List<Wisp> Wisps { get; set; }        
        public ServiceSubscription<IGroupLeaderService> GroupLeaderService { get; set; }
        public BindableCollection<WispBlockViewModel> WispBlocks { get; set; }
        public string Message { get; set; }

        public GroupShellViewModel(IKernel kernel, IEventAggregator eventAggregator, BonfireNetworkManager networkManager, StorageManager storageManager, ProfileManager profileManager)
        {
            this.kernel = kernel;
            this.networkManager = networkManager;
            this.storageManager = storageManager;
            this.profileManager = profileManager;


            WispBlocks = new BindableCollection<WispBlockViewModel>();

            Wisps = SerializationHelper.DeserializeFileOrValue(storageManager.LocalDirectory("GroupWisps"), new List<Wisp>());

            foreach (var wisp in Wisps)
            {
                DisplayWisp(wisp);
            }

            eventAggregator.Subscribe(this);
        }

        public async Task Connect()
        {
            GroupLeaderService = networkManager.ConnectToGroupLeader();
            var lastTime = SerializationHelper.DeserializeFileOrValue(storageManager.LocalDirectory("LastSeen"), DateTime.MinValue.ToUniversalTime());
            await GroupLeaderService.Service.Connect(lastTime);
        }

        public async void Send(string message)
        {
            Message = "";
            NotifyOfPropertyChange(() => Message);
            // Maybe replace this with some sort of wisp builder type deal. Different plugins can add tags to the wisp builder which will
            // then get wrapped up when send is called.
            await GroupLeaderService.Service.PropogateWisp(
                new Wisp(
                    profileManager.MyUserId,
                    DateTime.Now.ToUniversalTime(),
                    new Dictionary<string, WispTag>
                    {
                        {"Text", new TextTag(message)}
                    }));
        }

        public void Handle(Wisp wisp)
        {
            Wisps.Add(wisp);
            DisplayWisp(wisp);
        }

        void DisplayWisp(Wisp wisp)
        {
            var wispViewModel = new WispViewModel(wisp);
            WispBlockViewModel latestBlockBefore = null;
            int latestBlockIndex = 0;
            for (int i = 0; i < WispBlocks.Count; i++)
            {
                var nextBlock = WispBlocks[i];
                if (nextBlock.EarliestTime < wisp.TimeCreated)
                {
                    latestBlockBefore = nextBlock;
                    latestBlockIndex = i;
                }
                else
                {
                    break;
                }
            }

            if (latestBlockBefore != null)
            {
                if (latestBlockBefore.UserId == wisp.UserId)
                {
                    latestBlockBefore.AddWisp(wispViewModel);
                }
                else
                {
                    if (latestBlockIndex != WispBlocks.Count - 1)
                    {
                        if (WispBlocks[latestBlockIndex + 1].UserId == wisp.UserId)
                        {
                            WispBlocks[latestBlockIndex + 1].AddWisp(wispViewModel);
                        }
                        else
                        {
                            var wispBlockViewModel =
                                kernel.Get<WispBlockViewModel>(new ConstructorArgument("userId", wisp.UserId));
                            wispBlockViewModel.AddWisp(wispViewModel);
                            WispBlocks.Insert(latestBlockIndex + 1, wispBlockViewModel);
                        }
                    }
                }
            }
            else
            {
                if (WispBlocks.Count != 0 && WispBlocks[0].UserId == wisp.UserId)
                {
                    WispBlocks[0].AddWisp(wispViewModel);
                }
                else
                {
                    var wispBlockViewModel = kernel.Get<WispBlockViewModel>(new ConstructorArgument("userId", wisp.UserId));
                    wispBlockViewModel.AddWisp(wispViewModel);
                    WispBlocks.Add(wispBlockViewModel);
                }
            }
        }


        public void KeyDown(KeyEventArgs args, string message)
        {
            if (args.Key == Key.Enter)
            {
                Send(message);
            }
        }

        protected override void OnDeactivate(bool close)
        {
            SerializationHelper.SerializeToFile(storageManager.LocalDirectory("GroupWisps"), Wisps);
            SerializationHelper.SerializeToFile(storageManager.LocalDirectory("LastSeen"), DateTime.Now.ToUniversalTime());
        }

        protected override void OnViewLoaded(object view)
        {
            groupShellView = (GroupShellView)view;
            groupShellView.ScrollViewer.ScrollChanged += ScrollViewer_ScrollChanged;
            groupShellView.Message.Focus();
            ScrollIfNeeded();
        }

        private void ScrollIfNeeded()
        {
            if (autoStuck)
            {
                var scrollViewer = groupShellView.ScrollViewer;
                scrollViewer.ScrollToBottom();
            }
        }

        void ScrollViewer_ScrollChanged(object sender, ScrollChangedEventArgs e)
        {
            if (e.VerticalOffset == groupShellView.ScrollViewer.ScrollableHeight)
            {
                autoStuck = true;
            }
            else
            {
                autoStuck = false;
            }
        }
    }
}
