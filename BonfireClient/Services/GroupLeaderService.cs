using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BonfireClient.Events;
using BonfireClient.Model;
using Caliburn.Micro;
using Lidgren.Network;
using NetworkingLibrary;

namespace BonfireClient.Services
{
    public class GroupLeaderService : Service, IHandle<SaveEvent>
    {
        StorageManager storageManager;

        public List<ServiceSubscription<IBonfirePeerService>> Peers = new List<ServiceSubscription<IBonfirePeerService>>(); 

        public List<Wisp> Wisps { get; set; }

        public GroupLeaderService(IEventAggregator eventAggregator, StorageManager storageManager)
        {
            eventAggregator.Subscribe(this);
            
            this.storageManager = storageManager;

            Wisps =
                SerializationHelper.DeserializeFileOrValue(storageManager.LocalDirectory("GroupLeaderWisps"),
                    new List<Wisp>());
        }
 
        public void Connect(DateTime lastSeen)
        {
            var peer = NetworkManager.SubscribeToService<IBonfirePeerService>("BonfirePeerService",
                CallingConnection);
            Peers.Add(peer);
            foreach (var wisp in Wisps.Where(w => w.TimeCreated > lastSeen))
            {
                peer.Service.RecieveWisp(wisp);
            }

            var groupFilesPath = storageManager.GroupLeaderStorage;
            foreach (var file in Directory.EnumerateFiles(groupFilesPath))
            {
                var filePath = Path.Combine(groupFilesPath, file);
                if ((File.GetLastAccessTimeUtc(filePath) - lastSeen).TotalSeconds > 0)
                {
                    peer.Service.GroupFileUpdated(file, File.ReadAllBytes(filePath));
                }
            }
        }

        public void PropogateWisp(Wisp wispToSend)
        {
            Wisps.Add(wispToSend);
            Peers.ForEach(p => p.Service.RecieveWisp(wispToSend));
        }

        public void PublishOrUpdateGroupFile(string fileName, byte[] file)
        {
            var filePath = storageManager.LocalGroupLeaderDirectory(fileName);
            File.WriteAllBytes(filePath, file);
            Peers.ForEach(p => p.Service.GroupFileUpdated(fileName, file));
        }

        public byte[] GetGroupFile(string fileName)
        {
            var filePath = storageManager.LocalGroupLeaderDirectory(fileName);
            if (File.Exists(fileName))
            {
                return File.ReadAllBytes(filePath);
            }
            return null;
        }

        public void PublishScript(string name, byte[] archive)
        {
            Peers.ForEach(p => p.Service.PublishScript(name, archive));
        }

        public override string GetServiceName()
        {
            return "GroupLeaderService";
        }

        public void Handle(SaveEvent message)
        {
            SerializationHelper.SerializeToFile(storageManager.LocalDirectory("GroupLeaderWisps"), Wisps);
        }
    }
}
