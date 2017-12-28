using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using ProtoBuf;
using NetworkingLibrary;

namespace BonfireNetworking
{
    [ProtoContract]
    public class DataTag : WispTag
    {
        [ProtoMember(1)]
        public byte[] Data { get; set; }

        public DataTag() { }

        public DataTag(byte[] data)
        {
            Data = data;
        }

        public static DataTag Serialize<T>(T obj)
        {
            return new DataTag(SerializationHelper.Serialize(obj));
        }

        public T Deserialize<T>()
        {
            return SerializationHelper.Deserialize<T>(Data);
        }        
    }
}
