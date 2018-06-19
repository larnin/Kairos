using Sirenix.OdinInspector;
using Sirenix.Serialization;
using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[Serializable]
[ShowOdinSerializedPropertiesInInspector]
public class EventClip : PlayableAsset, ITimelineClipAsset, ISerializationCallbackReceiver, ISupportsPrefabSerialization
{
    public bool _ExecuteInEditMode = false;

    [SerializeField] public BaseAction m_action;

    [SerializeField, HideInInspector]
    private SerializationData serializationData;

    SerializationData ISupportsPrefabSerialization.SerializationData { get { return this.serializationData; } set { this.serializationData = value; } }

    void ISerializationCallbackReceiver.OnAfterDeserialize()
    {
        UnitySerializationUtility.DeserializeUnityObject(this, ref this.serializationData);
    }

    void ISerializationCallbackReceiver.OnBeforeSerialize()
    {
        UnitySerializationUtility.SerializeUnityObject(this, ref this.serializationData);
    }

    public ClipCaps clipCaps
    {
        get { return ClipCaps.None; }
    }

    public override Playable CreatePlayable (PlayableGraph graph, GameObject owner)
    {
        var playable = ScriptPlayable<EventBehaviour>.Create (graph);
        EventBehaviour clone = playable.GetBehaviour ();
        clone._EventClip = this;
        clone._Resolver = graph.GetResolver();
        return playable;
    }

    public void Trigger(IExposedPropertyTable resolver, GameObject obj)
    {
        if (m_action != null)
            m_action.trigger(obj);
    }

    public void TriggerEnd(IExposedPropertyTable resolver, GameObject obj)
    {
        if (m_action != null)
            m_action.triggerEnd(obj);
    }
}
