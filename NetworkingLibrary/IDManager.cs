using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NetworkingLibrary
{
    public class IdManager
    {
        public long CurrentId { get; set; }

        public IdManager() { }
        public IdManager(long initialId) { CurrentId = initialId; }

        public long GetNextId()
        {
            var returnId = CurrentId;
            CurrentId ++;
            return returnId;
        }
    }
}
