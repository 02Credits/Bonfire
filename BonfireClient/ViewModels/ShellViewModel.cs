using System;
using System.Windows.Input;
using BonfireClient.Views;
using Caliburn.Micro;
using MahApps.Metro.Controls;
using NetworkingLibrary;
using Ninject;

namespace BonfireClient.ViewModels
{
    public class ShellViewModel : Screen
    {
        IKernel kernel;
        BonfireNetworkManager networkManager;
        PopupManager popupManager;
        ShellView shellView;

        Object mainViewModel;
        public Object MainViewModel
        {
            get { return mainViewModel; }
            set
            {
                if (value != MainViewModel)
                {
                    mainViewModel = value;
                    NotifyOfPropertyChange(() => MainViewModel);
                }
            }
        }

        Object flyoutViewModel;
        public Object FlyoutViewModel
        {
            get { return flyoutViewModel; }
            set
            {
                if (value != FlyoutViewModel)
                {
                    flyoutViewModel = value;
                    NotifyOfPropertyChange(() => FlyoutViewModel);
                }
            }
        }

        bool flyoutVisible;
        public bool FlyoutVisible
        {
            get { return flyoutVisible; }
            set
            {
                if (value != FlyoutVisible)
                {
                    flyoutVisible = value;
                    NotifyOfPropertyChange(() => FlyoutVisible);
                }
            }
        }
        string flyoutHeader;
        public string FlyoutHeader
        {
            get { return flyoutHeader; }
            set
            {
                if (value != FlyoutHeader)
                {
                    flyoutHeader = value;
                    NotifyOfPropertyChange(() => FlyoutHeader);
                }
            }
        }

        Position flyoutPosition;
        public Position FlyoutPosition
        {
            get { return flyoutPosition; }
            set
            {
                if (value != FlyoutPosition)
                {
                    flyoutPosition = value;
                    NotifyOfPropertyChange(() => FlyoutPosition);
                }
            }
        }

        double flyoutHeight;
        public double FlyoutHeight
        {
            get { return flyoutHeight; }
            set
            {
                if (value != FlyoutHeight)
                {
                    flyoutHeight = value;
                    NotifyOfPropertyChange(() => FlyoutHeight);
                }
            }
        }

        double flyoutWidth;
        public double FlyoutWidth
        {
            get { return flyoutWidth; }
            set
            {
                if (value != FlyoutWidth)
                {
                    flyoutWidth = value;
                    NotifyOfPropertyChange(() => FlyoutWidth);
                }
            }
        }

        public ShellViewModel(IKernel kernel, BonfireNetworkManager networkManager, PopupManager popupManager)
        {
            this.kernel = kernel;

            DisplayName = "Bonfire";

            this.networkManager = networkManager;
            this.popupManager = popupManager;

            MainViewModel = kernel.Get<EmptyGroupViewModel>();
        }

        public void ShowFlyout(Object viewModel, string header, float size = 200, Position position = Position.Bottom)
        {
            FlyoutViewModel = viewModel;
            FlyoutHeader = header;
            if (position == Position.Top || position == Position.Bottom)
            {
                FlyoutWidth = shellView.Width;
                FlyoutHeight = size;
            }
            else
            {
                FlyoutWidth = size;
                FlyoutHeight = shellView.Height;
            }
            FlyoutPosition = position;
            FlyoutVisible = true;
        }

        public void KeyDown(KeyEventArgs args)
        {
            if (args.Key == Key.Escape || args.Key == Key.Enter)
            {
                FlyoutVisible = false;
            }
        }

        public void Host()
        {
            if (networkManager.HostGroup())
            {
                popupManager.MessageBox("Host", "Host Started");
            }
            else
            {
                popupManager.MessageBox("Host", "Host Already Running Ya Nerd.");
            }
        }

        public async void Connect()
        {
            if (MainViewModel is EmptyGroupViewModel)
            {
                //var progressManager = popupManager.ProgressBox("Connecting", "Connecting, please wait.");

                bool failed = false;
                try
                {
                    var groupShellViewModel = kernel.Get<GroupShellViewModel>();
                    await groupShellViewModel.Connect();
                    //await progressManager.Finish();
                    MainViewModel = groupShellViewModel;
                }
                catch (TransmitionFailedException)
                {
                    failed = true;
                }

                if (failed)
                {
                    //await progressManager.Finish();
                    popupManager.MessageBox("Connection Failed", "Could not connect.");
                }
            }
            else
            {
                popupManager.MessageBox("Already Connected", "Already connected ya dork.");
            }
        }

        protected override void OnViewLoaded(object view)
        {
            shellView = (ShellView)view;
            popupManager.Window = shellView;
        }
    }
}