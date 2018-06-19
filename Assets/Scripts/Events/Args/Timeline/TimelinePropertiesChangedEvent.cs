using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


public class TimelinePropertiesChangedEvent : EventArgs
{
    public TimelinePropertiesChangedEvent(bool _rewind)
    {
        rewind = _rewind;
    }

    public bool rewind;
}
