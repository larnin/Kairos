using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class LockPlayerControlesEvent : EventArgs
{
    public LockPlayerControlesEvent(bool _locked)
    {
        locked = _locked;
    }

    public bool locked;
}