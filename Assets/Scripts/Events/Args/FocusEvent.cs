using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class FocusEvent : EventArgs
{
    public FocusEvent(bool _enable)
    {
        enable = _enable;
    }

    public bool enable;
}
