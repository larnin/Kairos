using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using DG.Tweening;

[Serializable]
public class ScaleBehaviour : PlayableBehaviour
{

    public bool _ExecuteInEditMode = false;
    public Vector3 StartScale;
    public Vector3 EndScale;
    public Ease ease = Ease.Linear;

    bool playing = false;

    public override void OnGraphStart (Playable playable)
    {
        
    }

    public void exec(double time, double start, double end, Transform transform)
    {
        if (_ExecuteInEditMode || Application.isPlaying)
        {
            if(playing)
            {
                if (time < start)
                    transform.localScale = StartScale;
                if (time > end)
                    transform.localScale = EndScale;
                playing = false;
            }

            if (time < start || time > end)
                return;

            playing = true;

            var t = (time - start) / (end - start);

            var scale = Vector3.Lerp(StartScale, EndScale, DOVirtual.EasedValue(0, 1, (float)t, ease));
            transform.localScale = scale;
        }
    }
}
