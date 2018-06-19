using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[Serializable]
public class ScaleClip : PlayableAsset, ITimelineClipAsset
{
    public ScaleBehaviour template = new ScaleBehaviour ();

    public ClipCaps clipCaps
    {
        get { return ClipCaps.None; }
    }

    public override Playable CreatePlayable (PlayableGraph graph, GameObject owner)
    {
        var playable = ScriptPlayable<ScaleBehaviour>.Create (graph, template);
        ScaleBehaviour clone = playable.GetBehaviour ();
        return playable;
    }
}
