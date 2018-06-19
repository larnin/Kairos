using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class MaskSelectedEvent : EventArgs
{
    public MaskSelectedEvent(bool _valid)
    {
        valid = _valid;
    }

    public bool valid;
}
