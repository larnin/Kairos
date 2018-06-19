using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


public class PauseTimelineEvent : EventArgs
{
    public PauseTimelineEvent(bool _paused)
    {
        paused = _paused;
    }

    public bool paused;
}
