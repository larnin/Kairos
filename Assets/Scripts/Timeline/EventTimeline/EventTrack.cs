using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[TrackColor(1f, 0.1f, 0f)]
[TrackClipType(typeof(EventClip))]
[TrackBindingType(typeof(GameObject))]
public class EventTrack : TrackAsset
{
    public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
    {
        ScriptPlayable<EventMixerBehaviour> result = ScriptPlayable<EventMixerBehaviour>.Create(graph, inputCount);
        result.GetBehaviour()._clips = GetClips() as TimelineClip[];
        return result;

        //return ScriptPlayable<EventTestMixerBehaviour>.Create (graph, inputCount);
    }
}
