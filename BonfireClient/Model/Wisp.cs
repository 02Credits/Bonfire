using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading.Tasks;
using ProtoBuf;

namespace BonfireClient.Model
{
    [ProtoContract]
    public class Wisp
    {
        [ProtoMember(1)]
        public Dictionary<string, WispTag> Tags { get; set; }

        [ProtoMember(3)]
        public Guid UserId { get; set; }

        [ProtoMember(2)]
        public DateTime TimeCreated { get; set; }

        public Wisp() { }

        public Wisp(Guid userId, DateTime timeCreated)
            : this(userId, timeCreated, new Dictionary<string, WispTag>()) { }

        public Wisp(Guid userId, DateTime timeCreated, Dictionary<string, WispTag> tags)
        {
            Tags = tags;
            UserId = userId;
            TimeCreated = timeCreated;
        }
    }
}
