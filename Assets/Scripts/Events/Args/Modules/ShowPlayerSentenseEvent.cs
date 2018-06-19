using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class ShowPlayerSentenseEvent : EventArgs
{
    public ShowPlayerSentenseEvent(string _sentense)
    {
        sentense = _sentense;
    }

    public string sentense;
}