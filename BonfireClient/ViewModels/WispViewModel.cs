using BonfireClient.Model;
using Caliburn.Micro;

namespace BonfireClient.ViewModels
{
    public class WispViewModel : PropertyChangedBase
    {
        public string Text
        {
            get { return ((TextTag) Wisp.Tags["Text"]).Text; }
        }

        public Wisp Wisp { get; set; }

        public WispViewModel(Wisp wisp)
        {
            Wisp = wisp;
        }
    }
}
