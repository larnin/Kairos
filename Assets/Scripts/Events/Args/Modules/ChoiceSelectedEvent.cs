﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class ChoiceSelectedEvent : EventArgs
{
    public ChoiceSelectedEvent(int _index)
    {
        index = _index;
    }

    public int index;
}