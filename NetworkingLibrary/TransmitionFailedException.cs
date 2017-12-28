using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NetworkingLibrary
{
    public class TransmitionFailedException : Exception 
    {
        public TransmitionFailedException() : base() { }
        public TransmitionFailedException(string message) : base(message) { }
        public TransmitionFailedException(string message, Exception e) : base(message, e) { }
    }
}
