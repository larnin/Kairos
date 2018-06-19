using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class AddBalanceOfCoherenceValueEvent : EventArgs
{
    public AddBalanceOfCoherenceValueEvent(bool _isRightChoice, float _choiceValue)
    {
        isRightChoice = _isRightChoice;
        choiceValue = _choiceValue;
    }

    public bool isRightChoice;
    public float choiceValue;
}
