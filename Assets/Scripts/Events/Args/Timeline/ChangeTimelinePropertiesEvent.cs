using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


public class ChangeTimelinePropertiesEvent : EventArgs
{
    public ChangeTimelinePropertiesEvent(List<String> _properties, float _balanceOfCoherence = 0, bool _createRewindPoint = true, bool _reset = false)
    {
        createRewindPoint = _createRewindPoint;
        properties = _properties;
        balanceOfCoherence = _balanceOfCoherence;
        reset = _reset;
    }

    public bool createRewindPoint;
    public bool reset;
    public List<string> properties;
    public float balanceOfCoherence;
}
