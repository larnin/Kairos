using DG.Tweening;
using Sirenix.OdinInspector;
using Sirenix.Serialization;
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

[Serializable]
[ShowOdinSerializedPropertiesInInspector]
public class MaterialClip : PlayableAsset, ITimelineClipAsset, ISerializationCallbackReceiver, ISupportsPrefabSerialization
{
    public MaterialBehaviour template = new MaterialBehaviour ();
    public List<BaseProperty> m_properties = new List<BaseProperty>();

    public ClipCaps clipCaps
    {
        get { return ClipCaps.None; }
    }

    public override Playable CreatePlayable (PlayableGraph graph, GameObject owner)
    {
        var playable = ScriptPlayable<MaterialBehaviour>.Create (graph, template);
        MaterialBehaviour clone = playable.GetBehaviour ();
        clone._clip = this;
        return playable;
    }

    [Serializable]
    public abstract class BaseProperty
    {
        public string propertyName;
        public Ease ease = Ease.Linear;
        public abstract void exec(Material m, float value);
    }

    public class FloatProperty : BaseProperty
    {
        public float startValue;
        public float endValue;

        public override void exec(Material m, float value)
        {
            value = DOVirtual.EasedValue(0, 1, value, ease);
            m.SetFloat(propertyName, (endValue - startValue) * value + startValue);
        }
    }

    public class Vector3Property : BaseProperty
    {
        public Vector3 startValue;
        public Vector3 endValue;

        public override void exec(Material m, float value)
        {
            value = DOVirtual.EasedValue(0, 1, value, ease);
            m.SetVector(propertyName, (endValue - startValue) * value + startValue);
        }
    }

    public class ColorProperty : BaseProperty
    {
        public Color startValue;
        public Color endValue;

        public override void exec(Material m, float value)
        {
            value = DOVirtual.EasedValue(0, 1, value, ease);
            m.SetColor(propertyName, (endValue - startValue) * value + startValue);
        }
    }

    [SerializeField, HideInInspector, ExcludeDataFromInspector]
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
}
