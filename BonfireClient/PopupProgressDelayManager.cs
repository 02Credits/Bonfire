using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BonfireClient.Views;
using MahApps.Metro.Controls.Dialogs;

namespace BonfireClient
{
    public class PopupProgressDelayManager
    {
        ShellView window;
        string title;
        string message;

        ProgressDialogController controller;
        bool finished;

        public PopupProgressDelayManager(ShellView window, string title, string message)
        {
            this.window = window;
            this.title = title;
            this.message = message;
            Activate();
        }

        public async void Activate()
        {
            await Task.Delay(500);
            if (!finished)
            {
                controller = await window.ShowProgressAsync(title, message);
                controller.SetIndeterminate();
            }
        }

        public async Task Finish()
        {
            finished = true;
            if (controller != null)
            {
                await controller.CloseAsync();
            }
        }
    }
}
