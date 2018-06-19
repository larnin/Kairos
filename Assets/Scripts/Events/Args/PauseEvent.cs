using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class PauseEvent : EventArgs
{
    public PauseEvent(bool _paused)
    {
        paused = _paused;
    }

    public bool paused;
}
