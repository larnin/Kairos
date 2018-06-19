using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class TimelineUpdateEvent : EventArgs
{
    public TimelineUpdateEvent(float _currentTime, float _totalTime, float _deltaTime)
    {
        currentTime = _currentTime;
        totalTime = _totalTime;
        deltaTime = _deltaTime;
    }

    public float currentTime;
    public float deltaTime;
    public float totalTime;
}
