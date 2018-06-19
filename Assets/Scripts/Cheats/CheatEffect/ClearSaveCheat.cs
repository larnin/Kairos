using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ClearSaveCheat : BaseCheatEffect
{
    const float maxTime = 2;

    float m_time = 0;

    public override void onGui()
    {
        GUI.Label(new Rect(20, 20, 200, 40), "Save cleared");
    }

    public override bool onUpdate()
    {
        if(m_time == 0)
            Event<ChangeTimelinePropertiesEvent>.Broadcast(new ChangeTimelinePropertiesEvent(new List<string>(), 0, false, true));

        m_time += Time.deltaTime;
        if(m_time >= maxTime)
        {
            m_time = 0;
            return false;
        }

        return true;
    }
}
