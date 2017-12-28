using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ProtoBuf;

namespace BonfireClient.Model
{
    [ProtoContract]
    public class TextTag : WispTag
    {
        [ProtoMember(1)]
        public string Text { get; set; }

        public TextTag() { }

        public TextTag(string text)
        {
            Text = text;
        }
    }
}
