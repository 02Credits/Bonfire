using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BonfireClient.Events
{
    public class ProfileChangedEvent
    {
        public Guid UserId { get; set; }

        public ProfileChangedEvent(Guid userId)
        {
            UserId = userId;
        }
    }
}
