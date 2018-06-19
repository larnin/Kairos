using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class GiveClueDataEvent : EventArgs
{
    public GiveClueDataEvent(string _text)
    {
        text = _text;
    }

    public string text;
}