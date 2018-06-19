using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class TimelinePauseEvent : EventArgs
{
    public TimelinePauseEvent(bool _paused)
    {
        paused = _paused;
    }

    public bool paused;
}
