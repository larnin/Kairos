using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[TrackColor(1f, 0f, 0.6f)]
[TrackClipType(typeof(ConditionalEventClip))]
[TrackBindingType(typeof(GameObject))]
public class ConditionalEventTrack : TrackAsset
{
    public Condition m_condition;

    public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
    {
        ScriptPlayable<ConditionalEventMixerBehaviour> result = ScriptPlayable<ConditionalEventMixerBehaviour>.Create(graph, inputCount);
        result.GetBehaviour()._clips = GetClips() as TimelineClip[];
        result.GetBehaviour().m_condition = m_condition;
        return result;
    }
}
