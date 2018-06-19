using DG.Tweening;
using Sirenix.OdinInspector;
using Sirenix.Serialization;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ShowOdinSerializedPropertiesInInspector]
public abstract class BaseTextEffectLogic : ScriptableObject, ISerializationCallbackReceiver, ISupportsPrefabSerialization
{
    public BaseContinuousTextEffectLogic m_baseContinuous = null;

    protected List<Letter> m_letters;
    protected Transform m_transformText;
    protected Func<int, float> m_action = null;

    public abstract void initialize(List<Letter> _letters, Transform transformText);
    public abstract IEnumerator run(bool canFastText = false);
    public void setAction(Func<int, float> action) { m_action = action; }
    
    protected float m_localTimeScale = 1f;
    protected int m_currentLetter = 0;

    protected List<DG.Tweening.Tween> m_normalTween = new List<DG.Tweening.Tween>();
    protected List<DG.Tweening.Tween> m_unscaledTween = new List<DG.Tweening.Tween>();

    // odin reimplation 
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
    //------

    public void reset()
    {
        foreach (DG.Tweening.Tween e in m_normalTween)
        {
            if (e != null)
            {
                e.Kill();
            }
        }

        foreach (DG.Tweening.Tween e in m_normalTween)
        {
            if (e != null)
            {
                e.Kill();
            }
        }

        foreach (DG.Tweening.Tween e in m_unscaledTween)
        {
            if (e != null)
            {
                e.Kill();
            }
        }

        foreach (DG.Tweening.Tween e in m_unscaledTween)
        {
            if (e != null)
            {
                e.Kill();
            }
        }


        m_normalTween.Clear();
        m_unscaledTween.Clear();

        if(m_baseContinuous != null)
        {
            if(m_baseContinuous != null && m_transformText && m_transformText.GetComponent<TMPro.TMP_Text>())
                m_baseContinuous.globalReset(m_transformText.GetComponent<TMPro.TMP_Text>());
        }

        if(m_letters != null)
        {
            m_letters.Clear();
        }
    }


    public void setLocalTimeScale(float newValue)
    {
        m_localTimeScale = newValue;
        foreach (DG.Tweening.Tween e in m_normalTween)
        {
            if(e != null)
            e.timeScale = newValue;
        }
        
    }

    public static List<Letter> createLetters(TMPro.TMP_Text textComponent, int validIndex = 0, int validLenght = 0)
    {
       // textComponent.ForceMeshUpdate();
        TMPro.TMP_TextInfo textInfo = textComponent.textInfo;
        List<Letter> letters = new List<Letter>();
        letters.Capacity = textInfo.characterCount;

        Color32[] vertexColors;
        Vector3[] vertices;
        Vector2[] uv0;
        Vector2[] uv2;
        int lenghtForEffect = textInfo.characterCount;
        if (validLenght != 0)
        {
            lenghtForEffect = validIndex + validLenght;
        }
        
        for (int i = validIndex; i < lenghtForEffect; i++)
        {
            // Skip characters that are not visible
            if (!textInfo.characterInfo[i].isVisible)
            {
                letters.Add(new Letter(i));
                continue;
            }

            int materialIndex = textInfo.characterInfo[i].materialReferenceIndex;
            int vertexIndex = textInfo.characterInfo[i].vertexIndex;

            vertices = textInfo.meshInfo[materialIndex].vertices;
            vertexColors = textInfo.meshInfo[materialIndex].colors32;
            uv0 = textInfo.meshInfo[materialIndex].uvs0;
            uv2 = textInfo.meshInfo[materialIndex].uvs2;
            
            letters.Add(new Letter(vertices, vertexColors, uv0, uv2, vertexIndex, i));
        }

        return letters;
    }

    public void keepOtherLetterInvisible(int iStart)
    {
        for (int i = iStart; i < m_letters.Count; i++)
        {
            if (!m_letters[i].isVisible)
            {
                continue;
            }

            m_letters[i].VC[0 + m_letters[i].vertexIndex].a = 0;
            m_letters[i].VC[1 + m_letters[i].vertexIndex].a = 0;
            m_letters[i].VC[2 + m_letters[i].vertexIndex].a = 0;
            m_letters[i].VC[3 + m_letters[i].vertexIndex].a = 0;
        }
    }
}
