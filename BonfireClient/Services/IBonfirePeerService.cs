using System.Threading.Tasks;
using BonfireClient.Model;

namespace BonfireClient.Services
{
    public interface IBonfirePeerService
    {
        Task RecieveWisp(Wisp wisp);
        Task GroupFileUpdated(string fileName, byte[] archive);
        Task PublishScript(string name, byte[] archive);
    }
}
