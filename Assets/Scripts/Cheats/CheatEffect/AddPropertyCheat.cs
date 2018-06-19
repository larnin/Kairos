using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

class AddPropertyCheat : BaseCheatEffect
{
    string text = "";

    public override void onGui()
    {
        GUI.Label(new Rect(20, 20, 200, 20), "Add property");
        text = GUI.TextField(new Rect(20, 50, 200, 20), text);
    }

    public override bool onUpdate()
    {
        if(Input.GetKeyDown("return"))
        {
            SaveAttributes.setTimelineProperty(text, true);
            Event<ChangeTimelinePropertiesEvent>.Broadcast(new ChangeTimelinePropertiesEvent(new List<string>(), 0, false));
            text = "";
            return false;
        }
        if (Input.GetKeyDown("escape"))
        {
            text = "";
            return false;
        }

        return true;
    }
}
