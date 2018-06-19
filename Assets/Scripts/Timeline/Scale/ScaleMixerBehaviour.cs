using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

public class ScaleMixerBehaviour : PlayableBehaviour
{
    public TimelineClip[] _clips;
    
    public override void ProcessFrame(Playable playable, FrameData info, object playerData)
    {
        Transform trackBinding = playerData as Transform;

        if (!trackBinding)
            return;

        int inputCount = playable.GetInputCount ();
        double time = playable.GetGraph().GetRootPlayable(0).GetTime();

        for (int i = 0; i < inputCount; i++)
        {
            float inputWeight = playable.GetInputWeight(i);
            ScriptPlayable<ScaleBehaviour> inputPlayable = (ScriptPlayable<ScaleBehaviour>)playable.GetInput(i);
            ScaleBehaviour input = inputPlayable.GetBehaviour ();

            input.exec(time, _clips[i].start, _clips[i].end, trackBinding);
        }
    }
}
