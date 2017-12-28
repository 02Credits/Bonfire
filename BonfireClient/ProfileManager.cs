using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BonfireClient.Events;
using Caliburn.Micro;
using NetworkingLibrary;
using ProtoBuf;

namespace BonfireClient
{
    public class ProfileManager : IHandle<SaveEvent>
    {
        BonfireNetworkManager networkManager;
        StorageManager storageManager;

        public Dictionary<Guid, UserProfile> Users { get; set; }
        public Guid MyUserId { get; set; }
        public UserProfile MyProfile { get { return Users[MyUserId]; } }

        public ProfileManager(IEventAggregator eventAggregator, BonfireNetworkManager networkManager, StorageManager storageManager)
        {
            eventAggregator.Subscribe(this);

            this.storageManager = storageManager;
            this.networkManager = networkManager;

            Users = SerializationHelper.DeserializeFileOrValue(Path.Combine(storageManager.LocalStorage, "Users"), new Dictionary<Guid, UserProfile>());
            MyUserId = SerializationHelper.DeserializeFileOrValue(Path.Combine(storageManager.LocalStorage, "MyUserId"), Guid.NewGuid());

            if (!Users.ContainsKey(MyUserId))
            {
                Users[MyUserId] = new UserProfile(MyUserId);
            }
        }

        public UserProfile GetProfile(Guid userId)
        {
            if (Users.ContainsKey(userId))
            {
                return Users[userId];
            }
            else
            {
                Users[userId] = new UserProfile(userId);
                // Queue server to fetch information.
                return Users[userId];
            }
        }

        public void Handle(SaveEvent message)
        {
            SerializationHelper.SerializeToFile(Path.Combine(storageManager.LocalStorage, "Users"), Users);
            SerializationHelper.SerializeToFile(Path.Combine(storageManager.LocalStorage, "MyUserId"), MyUserId);
        }
    }
}
