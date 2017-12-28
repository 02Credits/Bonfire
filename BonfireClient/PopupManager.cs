using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BonfireClient.Views;
using MahApps.Metro.Controls.Dialogs;

namespace BonfireClient
{
    public class PopupManager
    {
        public ShellView Window { get; set; }

        public void MessageBox(string title, string message)
        {
            Window.ShowMessageAsync(title, message);
        }

        public Task<string> InputBox(string title, string question)
        {
            return Window.ShowInputAsync(title, question);
        }

        public PopupProgressDelayManager ProgressBox(string title, string message)
        {
            return new PopupProgressDelayManager(Window, title, message);
        }
    }
}
