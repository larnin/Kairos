using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

public class ConditionalEventMixerBehaviour : PlayableBehaviour
{
    public TimelineClip[] _clips;
    public Condition m_condition;

    public override void ProcessFrame(Playable playable, FrameData info, object playerData)
    {
        GameObject trackBinding = playerData as GameObject;

        int inputCount = playable.GetInputCount ();
        double time = playable.GetGraph().GetRootPlayable(0).GetTime();

        for (int i = 0; i < inputCount; i++)
        {
            ScriptPlayable<ConditionalEventBehaviour> inputPlayable = (ScriptPlayable<ConditionalEventBehaviour>)playable.GetInput(i);
            ConditionalEventBehaviour input = inputPlayable.GetBehaviour ();

            input.Trigger(time, _clips[i].start, _clips[i].end, trackBinding, m_condition);
        }
    }
}
