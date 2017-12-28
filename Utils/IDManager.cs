using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Utils
{
    public class IDManager
    {
        public long CurrentID { get; set; }

        public IDManager() { }
        public IDManager(long initialID) { CurrentID = initialID; }


    }
}
