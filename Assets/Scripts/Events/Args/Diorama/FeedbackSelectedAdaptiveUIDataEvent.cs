using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class FeedbackSelectedAdaptiveUIDataEvent : EventArgs
{
    public FeedbackSelectedAdaptiveUIDataEvent(int _numero, float _newSize)
    {
        numero = _numero;
        newSize = _newSize;
    }

    public int numero;
    public float newSize;
}