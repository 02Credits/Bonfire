using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BonfireClient
{
    public class StorageManager
    {
        public string LocalStorage { get; set; }
        public string GroupStorage { get; set; }
        public string ScriptStorage { get; set; }
        public string GroupLeaderStorage { get; set; }

        public StorageManager()
        {
            LocalStorage = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Bonfire");
            GroupStorage = Path.Combine(LocalStorage, "GroupFiles");
            ScriptStorage = Path.Combine(LocalStorage, "Scripts");
            GroupLeaderStorage = Path.Combine(LocalStorage, "GroupLeaderStorage");

            CreateIfNotExists(LocalStorage);
            CreateIfNotExists(GroupStorage);
            CreateIfNotExists(ScriptStorage);
            CreateIfNotExists(GroupLeaderStorage);
        }

        public string LocalDirectory(string pathInLocalFolder)
        {
            return Path.Combine(LocalStorage, pathInLocalFolder);
        }

        public string LocalGroupDirectory(string pathInGroupStorage)
        {
            return Path.Combine(GroupStorage, pathInGroupStorage);
        }

        public string LocalScriptDirectory(string pathInScriptStorage)
        {
            return Path.Combine(ScriptStorage, pathInScriptStorage);
        }

        public string LocalGroupLeaderDirectory(string pathInGroupLeaderStorage)
        {
            return Path.Combine(GroupLeaderStorage, pathInGroupLeaderStorage);
        }

        private void CreateIfNotExists(string directoryName)
        {
            if (!Directory.Exists(directoryName))
            {
                Directory.CreateDirectory(directoryName);
            }
        }
    }
}
