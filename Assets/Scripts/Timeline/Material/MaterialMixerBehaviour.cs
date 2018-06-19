using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

public class MaterialMixerBehaviour : PlayableBehaviour
{
    public TimelineClip[] _clips;

    public override void ProcessFrame(Playable playable, FrameData info, object playerData)
    {
        Renderer trackBinding = playerData as Renderer;

        if (!trackBinding)
            return;

        int inputCount = playable.GetInputCount ();
        double time = playable.GetGraph().GetRootPlayable(0).GetTime();

        for (int i = 0; i < inputCount; i++)
        {
            float inputWeight = playable.GetInputWeight(i);
            ScriptPlayable<MaterialBehaviour> inputPlayable = (ScriptPlayable<MaterialBehaviour>)playable.GetInput(i);
            MaterialBehaviour input = inputPlayable.GetBehaviour ();

            input.exec(time, _clips[i].start, _clips[i].end, trackBinding);
        }
    }
}
