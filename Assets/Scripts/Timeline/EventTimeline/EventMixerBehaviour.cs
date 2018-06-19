using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

public class EventMixerBehaviour : PlayableBehaviour
{
    public TimelineClip[] _clips;

    public override void ProcessFrame(Playable playable, FrameData info, object playerData)
    {
        GameObject trackBinding = playerData as GameObject;

        int inputCount = playable.GetInputCount ();
        double time = playable.GetGraph().GetRootPlayable(0).GetTime();

        for (int i = 0; i < inputCount; i++)
        {
            ScriptPlayable<EventBehaviour> inputPlayable = (ScriptPlayable<EventBehaviour>)playable.GetInput(i);
            EventBehaviour input = inputPlayable.GetBehaviour ();

            input.Trigger(time, _clips[i].start, _clips[i].end, trackBinding);
        }
    }
}
