using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ProtoBuf;

namespace BonfireNetworking
{
    [ProtoContract]
    [ProtoInclude(1, typeof(TextTag))]
    [ProtoInclude(2, typeof(DataTag))]
    public class WispTag { }
}
