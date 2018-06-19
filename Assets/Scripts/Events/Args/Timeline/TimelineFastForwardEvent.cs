using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


public class TimelineFastForwardEvent : EventArgs
{
    public TimelineFastForwardEvent(bool _started, bool _forward)
    {
        started = _started;
        forward = _forward;

    }

    public bool started;
    public bool forward;
}
