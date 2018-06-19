using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class ChoiceIsSelectedAdaptiveUIDataEvent : EventArgs
{
    public ChoiceIsSelectedAdaptiveUIDataEvent(int _index)
    {
        index = _index;
    }

    public int index;
}