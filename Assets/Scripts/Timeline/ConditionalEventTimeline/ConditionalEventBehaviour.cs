using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[Serializable]
public class ConditionalEventBehaviour : PlayableBehaviour
{
    public ConditionalEventClip _EventClip;
    public IExposedPropertyTable _Resolver;
    double _lastTime = -1;

    public void Trigger(double time, double start, double end, GameObject obj, Condition condition)
    {
        if (_EventClip._ExecuteInEditMode || Application.isPlaying)
        {
            if ((_lastTime < start && time >= start ||
                _lastTime > time && time == start) && condition.check())
            {
                _EventClip.Trigger(_Resolver, obj);
            }

            if((_lastTime < end && time >= end ||
               _lastTime > time && time == end) && condition.check())
            {
                _EventClip.TriggerEnd(_Resolver, obj);
            }

            _lastTime = time;
        }
    }

    public override void OnGraphStart (Playable playable)
    {
        
    }
}
