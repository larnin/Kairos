using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ChangeBalanceOfCoherenceCheat : BaseCheatEffect
{
    float value = 0;
    public override void onGui()
    {
        GUI.Label(new Rect(20, 20, 200, 20), "Set balance of coherence value");
        float.TryParse(GUI.TextField(new Rect(20, 50, 200, 20), value.ToString()), out value);
    }

    public override bool onUpdate()
    {
        if (Input.GetKeyDown("return"))
        {
            Event<ChangeTimelinePropertiesEvent>.Broadcast(new ChangeTimelinePropertiesEvent(new List<string>(), value, false));
            value = 0;
            return false;
        }
        if (Input.GetKeyDown("escape"))
        {
            value = 0;
            return false;
        }

        return true;
    }
}