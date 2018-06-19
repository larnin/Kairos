using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class TimelineUpdateDioramaAction : BaseDioramaAction
{
    [ValueDropdown("getProperties")]
    [SerializeField] List<string> m_properties = new List<string>();
    [SerializeField] float m_balanceOfCoherence;

    List<string> getProperties()
    {
        var t = TimelineManager2Logic.instance();
        if (t == null)
        {
            t = UnityEngine.Object.FindObjectOfType<TimelineManager2Logic>();
            if(t == null)
                return new List<string>();
        }
        return t.properties;
    }

    public override void triggerBegin()
    {

    }

    public override void triggerEnd()
    {
        Event<ChangeTimelinePropertiesEvent>.Broadcast(new ChangeTimelinePropertiesEvent(m_properties, m_balanceOfCoherence));
    }
}