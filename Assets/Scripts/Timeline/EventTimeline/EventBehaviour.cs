using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[Serializable]
public class EventBehaviour : PlayableBehaviour
{
    public EventClip _EventClip;
    public IExposedPropertyTable _Resolver;
    double _lastTime = -1;

    public void Trigger(double time, double start, double end, GameObject obj)
    {
        if (_EventClip._ExecuteInEditMode || Application.isPlaying)
        {
            if (_lastTime < start && time >= start || _lastTime > time && time == start)
                _EventClip.Trigger(_Resolver, obj);

            if(_lastTime < end && time >= end)
                _EventClip.TriggerEnd(_Resolver, obj);
            
            // reversed
            if(_lastTime > start && time <= start)
                _EventClip.TriggerEnd(_Resolver, obj);

            if(_lastTime > end && time <= end && time > start)
                _EventClip.Trigger(_Resolver, obj);

            _lastTime = time;
        }
    }

    public override void OnGraphStart (Playable playable)
    {
        
    }
}
