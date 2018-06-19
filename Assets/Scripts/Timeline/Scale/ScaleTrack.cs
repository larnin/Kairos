using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[TrackColor(0.855f, 0.8623f, 0.87f)]
[TrackClipType(typeof(ScaleClip))]
[TrackBindingType(typeof(Transform))]
public class ScaleTrack : TrackAsset
{
    public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
    {
        ScriptPlayable<ScaleMixerBehaviour> result = ScriptPlayable<ScaleMixerBehaviour>.Create(graph, inputCount);
        result.GetBehaviour()._clips = GetClips() as TimelineClip[];
        return result;
    }
}
