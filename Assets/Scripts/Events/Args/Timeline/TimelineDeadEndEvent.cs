using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


public class TimelineDeadEndEvent : EventArgs
{
	public TimelineDeadEndEvent(float _duration)
	{
		duration = _duration;
	}

	public float duration;
}
 