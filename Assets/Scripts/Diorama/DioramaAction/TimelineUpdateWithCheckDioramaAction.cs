using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class TimelineUpdateWithCheckDioramaAction : BaseDioramaAction
{
    [ValueDropdown("getProperties")]
    [SerializeField]
    List<string> m_properties = new List<string>();
    [SerializeField] float m_balanceOfCoherence;

    List<string> getProperties()
    {
        var t = TimelineManager2Logic.instance();
        if (t == null)
        {
            t = UnityEngine.Object.FindObjectOfType<TimelineManager2Logic>();
            if (t == null)
                return new List<string>();
        }
        return t.properties;
    }

    public override void triggerBegin()
    {

    }

    public override void triggerEnd()
    {
        List<string> validProperties = new List<string>();
        foreach (var p in m_properties)
            if (!SaveAttributes.getTimelineProperty(p).enabled)
                validProperties.Add(p);

        if (validProperties.Count > 0)
            Event<ChangeTimelinePropertiesEvent>.Broadcast(new ChangeTimelinePropertiesEvent(validProperties, m_balanceOfCoherence));
    }
}