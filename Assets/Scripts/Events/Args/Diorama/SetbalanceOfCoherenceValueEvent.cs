using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


public class SetBalanceOfCoherenceValueEvent : EventArgs
{
    public SetBalanceOfCoherenceValueEvent(float _value)
    {
        value = _value;
    }

    public float value;
}
