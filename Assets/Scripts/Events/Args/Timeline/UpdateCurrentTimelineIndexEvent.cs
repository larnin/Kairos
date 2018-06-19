using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


public class UpdateCurrentTimelineIndexEvent : EventArgs
{
    public UpdateCurrentTimelineIndexEvent(int _index)
    {
        index = _index;
    }

    public int index;
}