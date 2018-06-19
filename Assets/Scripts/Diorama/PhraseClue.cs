using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using DG.Tweening;
using TMPro;

class PhraseClue : MonoBehaviour
{
    TextMeshProUGUI m_textMeshPro;
    [SerializeField] BaseTextEffectLogic m_textEffect = null;

    SubscriberList m_subscriberList = new SubscriberList();

    void Start()
    {
        m_textMeshPro = GetComponent<TextMeshProUGUI>();
        m_textMeshPro.text = "";
        m_subscriberList.Add(new Event<GiveClueDataEvent>.Subscriber(setText));
        m_subscriberList.Subscribe();
        m_textMeshPro.enabled = false;
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    void setText (GiveClueDataEvent ClueData)
    {
        if(ClueData.text != null && ClueData.text != "")
        {
            m_textMeshPro.enabled = true; 
            m_textEffect.reset();
            m_textMeshPro.text = ClueData.text;
            m_textMeshPro.ForceMeshUpdate();

            m_textEffect.initialize(BaseTextEffectLogic.createLetters(m_textMeshPro), transform);
            m_textMeshPro.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);
            m_textMeshPro.UpdateVertexData(TMP_VertexDataUpdateFlags.Vertices);
            StartCoroutine(m_textEffect.run());
        }
        else
        {
            StopAllCoroutines();
            m_textEffect.reset();
            m_textMeshPro.ForceMeshUpdate();
            m_textMeshPro.text = "";
            m_textMeshPro.enabled = false;
        }
    }

    void LateUpdate()
    {
        m_textMeshPro.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);
        m_textMeshPro.UpdateVertexData(TMP_VertexDataUpdateFlags.Vertices);
    }


    // qualityOfLife improvement : 
    void verifData()
    {

    }
}

