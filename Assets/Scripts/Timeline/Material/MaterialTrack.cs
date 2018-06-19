using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[TrackColor(0.855f, 0.8623f, 0.87f)]
[TrackClipType(typeof(MaterialClip))]
[TrackBindingType(typeof(Renderer))]
public class MaterialTrack : TrackAsset
{
    public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
    {
        ScriptPlayable<MaterialMixerBehaviour> result = ScriptPlayable<MaterialMixerBehaviour>.Create(graph, inputCount);
        result.GetBehaviour()._clips = GetClips() as TimelineClip[];
        return result;
    }
}
