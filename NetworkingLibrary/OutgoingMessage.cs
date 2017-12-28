using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Lidgren.Network;

namespace NetworkingLibrary
{
    public class OutgoingMessage
    {
        public DateTime TimeOriginallySent { get; set; }
        public DateTime TimeSinceLastResent { get; set; }
        public byte[] Data { get; set; }

        public OutgoingMessage(DateTime currentTime, byte[] data)
        {
            TimeOriginallySent = currentTime;
            TimeSinceLastResent = currentTime;
            Data = data;
        }
    }
}
