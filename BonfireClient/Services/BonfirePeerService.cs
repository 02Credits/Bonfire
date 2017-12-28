using System;
using System.IO;
using System.IO.Compression;
using BonfireClient.Model;
using Caliburn.Micro;
using NetworkingLibrary;

namespace BonfireClient.Services
{
    public class BonfirePeerService : Service
    {
        IEventAggregator eventAggregator;
        readonly StorageManager storageManager;

        public BonfirePeerService(IEventAggregator eventAggregator, StorageManager storageManager)
        {
            this.eventAggregator = eventAggregator;
            this.storageManager = storageManager;
        }

        public void RecieveWisp(Wisp wisp)
        {
            eventAggregator.PublishOnUIThread(wisp);
        }

        public void GroupFileUpdated(string fileName, byte[] file)
        {
            var filePath = storageManager.LocalGroupDirectory(fileName);
            File.WriteAllBytes(filePath, file);
        }

        public void PublishScript(string file, byte[] archiveData)
        {
            // REMOVE SCRIPT IF IT IS ALREADY RUNNING

            using (MemoryStream stream = new MemoryStream(archiveData))
            {
                using (ZipArchive archive = new ZipArchive(stream, ZipArchiveMode.Read))
                {
                    archive.ExtractToDirectory(storageManager.LocalGroupDirectory(Path.Combine("scripts", file)));
                }
            }

            // ADD SCRIPT TO RUNNING MODEL
        }

        public override string GetServiceName()
        {
            return "BonfirePeerService";
        }
    }
}
