using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Media.Imaging;
using ProtoBuf;

namespace BonfireClient
{
    [ProtoContract]
    public class UserProfile
    {
        [ProtoMember(1)]
        public Guid UserId { get; set; }

        [ProtoMember(2)]
        public string UserName { get; set; }

        string imagePath;
        [ProtoMember(3)]
        public string ImagePath
        {
            get { return imagePath; }
            set 
            { 
                imagePath = value;
                UpdateImage(); 
            }
        }

        public BitmapImage ImageSource { get; set; }

        public UserProfile() { }

        public UserProfile(Guid userId)
            : this()
        {
            UserId = userId;
            UpdateImage();
            UserName = "UserName";
        }

        public void UpdateImage()
        {
            ImageSource = new BitmapImage();
            ImageSource.BeginInit();
            if (ImagePath == null)
            {
                imagePath = "VRBaddie.png";
            }
            ImageSource.UriSource = new Uri(ImagePath, UriKind.RelativeOrAbsolute);
            ImageSource.CacheOption = BitmapCacheOption.OnLoad;
            ImageSource.EndInit();
        }
    }
}
