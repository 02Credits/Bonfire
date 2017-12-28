using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;
using BonfireClient.Model;

namespace BonfireClient.Services
{
    public interface IGroupLeaderService
    {
        Task Connect(DateTime lastSeen);
        Task PropogateWisp(Wisp wispToSend);
        Task PublishOrUpdateGroupFile(string fileName, byte[] file);
        Task<byte[]> GetGroupFile(string fileName);
    }
}
