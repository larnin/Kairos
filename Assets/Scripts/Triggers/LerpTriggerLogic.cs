using UnityEngine;
using System.Collections;
using Sirenix;
using Sirenix.OdinInspector;
using Sirenix.Serialization;
using DG.Tweening;

[ShowOdinSerializedPropertiesInInspector]
public class LerpTriggerLogic : TriggerBaseLogic, ISerializationCallbackReceiver, ISupportsPrefabSerialization
{
    abstract class LerpEffectBase
    {
        public abstract void exec(float pos);
    }

    class LightIntensityEffect : LerpEffectBase
    {
        public float start = 0;
        public float end = 0;
        public Light light;

        public override void exec(float pos)
        {
            light.intensity = start * pos + end * (1 - pos);
        }
    }

    [SerializeField] LerpEffectBase m_effect;
    [SerializeField] Ease m_ease = Ease.Linear;

    BoxCollider m_collider;

    bool m_inTrigger = false;
    Transform m_object;

    public override void onEnter(TriggerInteractionLogic entity)
    {
        if (!m_inTrigger)
        {
            m_object = entity.transform;
            m_inTrigger = true;
        }
    }

    public override void onExit(TriggerInteractionLogic entity)
    {
        if (m_inTrigger && entity.transform == m_object)
        {
            m_inTrigger = false;
            m_object = null;
        }
    }

    void Start()
    {
        m_collider = GetComponent<BoxCollider>();
    }
    
    void Update()
    {
        if(m_inTrigger && m_object)
        {
            var pos = transform.InverseTransformPoint(m_object.position);
            var value = Mathf.Clamp01(pos.x / m_collider.size.x + m_collider.size.x / 2);
            m_effect.exec(DOVirtual.EasedValue(0, 1, value, m_ease));
        }
    }

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
}
