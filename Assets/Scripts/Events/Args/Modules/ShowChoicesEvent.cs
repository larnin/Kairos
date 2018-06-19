using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


public class ShowChoicesEvent : EventArgs
{
    public ShowChoicesEvent(List<String> _choices)
    {
        choices = _choices;
    }

    public List<String> choices;
}