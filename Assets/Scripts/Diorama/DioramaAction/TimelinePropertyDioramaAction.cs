using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

class TimelinePropertyDioramaAction : BaseDioramaAction
{
    [SerializeField] string m_timelineProperty;

	public override void triggerBegin()
	{

	}

    public override void triggerEnd()
    {
        SaveAttributes.setTimelineProperty(m_timelineProperty, true);
        Event<TimelinePropertiesChangedEvent>.Broadcast(new TimelinePropertiesChangedEvent(false));
    }
}