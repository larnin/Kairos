using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;


public class DeadEndAction : BaseDioramaAction
{
	[SerializeField] float m_deadEndTime = 10;

    public override void triggerBegin()
    {

    }

    public override void triggerEnd()
    {
        Event<TimelineDeadEndEvent>.Broadcast(new TimelineDeadEndEvent(m_deadEndTime));
    }
}
