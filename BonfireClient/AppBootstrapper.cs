using System;
using System.Collections.Generic;
using System.Windows;
using BonfireClient.Events;
using BonfireClient.Services;
using BonfireClient.ViewModels;
using Caliburn.Micro;
using Ninject;

namespace BonfireClient {
    public class AppBootstrapper : BootstrapperBase {
        public IKernel Kernel { get; private set; }

        public AppBootstrapper() {
            Initialize();
        }

        protected override void Configure() {
            Kernel = new StandardKernel();

            Kernel.Bind<IWindowManager>().To<WindowManager>().InSingletonScope();
            Kernel.Bind<IEventAggregator>().To<EventAggregator>().InSingletonScope();

            Kernel.Bind<BonfireNetworkManager>().ToSelf().InSingletonScope();
            Kernel.Bind<ProfileManager>().ToSelf().InSingletonScope();
            Kernel.Bind<PopupManager>().ToSelf().InSingletonScope();
            Kernel.Bind<StorageManager>().ToSelf().InSingletonScope();
        }

        protected override object GetInstance(Type service, string key)
        {
            return Kernel.Get(service);
        }

        protected override IEnumerable<object> GetAllInstances(Type service)
        {
            return Kernel.GetAll(service);
        }

        protected override void BuildUp(object instance) {
            Kernel.Inject(instance);
        } 

        protected override void OnStartup(object sender, StartupEventArgs e) {
            DisplayRootViewFor<ShellViewModel>();
        }

        protected override void OnExit(object sender, EventArgs e)
        {
            Kernel.Get<IEventAggregator>().PublishOnUIThread(new SaveEvent());
        }
    }
}