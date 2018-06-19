using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class DemonDoneTalkingDataEvent : EventArgs
{
    public DemonDoneTalkingDataEvent(int _index)
    {
        indexOfAnswer = _index;
    }

    public int indexOfAnswer;
}