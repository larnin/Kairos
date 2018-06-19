using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class MaskAnswerEvent : EventArgs
{
    public MaskAnswerEvent(bool _valid)
    {
        valid = _valid;
    }

    public bool valid;
}
