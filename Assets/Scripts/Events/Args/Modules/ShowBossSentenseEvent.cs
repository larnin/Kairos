using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class ShowBossSentenseEvent : EventArgs
{
    public ShowBossSentenseEvent(string _sentense)
    {
        sentense = _sentense;
    }

    public string sentense;
}
