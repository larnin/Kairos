using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using DG.Tweening;

public class FadeTester : MonoBehaviour
{
    const float delayTimePerLetter = .1f;
    const float fadeDelay = 0.75f;

    private TMP_Text m_TextComponent;
    private TMP_TextInfo m_textInfo;

    private List<Letter> m_letters = new List<Letter>();

    
    void Awake()
    {
        m_TextComponent = GetComponent<TMP_Text>();
    }
    
    void Start () {
        m_TextComponent.ForceMeshUpdate();
        m_textInfo = m_TextComponent.textInfo;
        m_letters.Capacity = m_textInfo.characterCount;

        Color32[] vertexColors;
        Vector3[] vertices;

        for (int i = 0; i < m_textInfo.characterCount; i++)
        {
            // Skip characters that are not visible
            if (!m_textInfo.characterInfo[i].isVisible)
            {
                m_letters.Add(new Letter(i));
                continue;
            }
            
            int materialIndex = m_textInfo.characterInfo[i].materialReferenceIndex;
            int vertexIndex = m_textInfo.characterInfo[i].vertexIndex;

            vertices = m_textInfo.meshInfo[materialIndex].vertices;
            vertexColors = m_textInfo.meshInfo[materialIndex].colors32;
            
           // letters.Add(new Letter(vertices, vertexColors, vertexIndex));
        }


        StartCoroutine(fadeIn());
    }
	

	IEnumerator fadeIn()
    {

        
        for (int i = 0; i < m_textInfo.characterCount; i++)
        {
            if (!m_textInfo.characterInfo[i].isVisible)
            {
                continue;
            }

            m_letters[i].VC[0 + m_letters[i].vertexIndex].a = 0;
            m_letters[i].VC[1 + m_letters[i].vertexIndex].a = 0;
            m_letters[i].VC[2 + m_letters[i].vertexIndex].a = 0;
            m_letters[i].VC[3 + m_letters[i].vertexIndex].a = 0;

            m_letters[i].position = Vector3.up * 1f; 
        }

        m_TextComponent.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);
        m_TextComponent.UpdateVertexData(TMP_VertexDataUpdateFlags.Vertices);



        for (int i = 0; i < m_textInfo.characterCount; i++)
        {
            if (!m_textInfo.characterInfo[i].isVisible)
            {
                continue;
            }
            
            FadeDotTween(i);
            yield return new WaitForSeconds(delayTimePerLetter);
        }
	}

    void Update()
    {
        DOTween.ManualUpdate(Time.deltaTime, Time.unscaledDeltaTime);
        m_TextComponent.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);
        m_TextComponent.UpdateVertexData(TMP_VertexDataUpdateFlags.Vertices);
    }

    void FadeDotTween(int i)
    {
        DOTween.ToAlpha(() => m_letters[i].VC[0 + m_letters[i].vertexIndex],
        x =>
        {
            m_letters[i].VC[0 + m_letters[i].vertexIndex] = x;
            m_letters[i].VC[1 + m_letters[i].vertexIndex] = x;
            m_letters[i].VC[2 + m_letters[i].vertexIndex] = x;
            m_letters[i].VC[3 + m_letters[i].vertexIndex] = x;
        }, 1f, fadeDelay).SetEase(Ease.InQuad).SetUpdate(UpdateType.Manual);

        DOTween.To(() => m_letters[i].position,
        x =>
        {
            m_letters[i].position = x;
            m_letters[i].VV[0 + m_letters[i].vertexIndex] = x + m_letters[i].initialVV[0];
            m_letters[i].VV[1 + m_letters[i].vertexIndex] = x + m_letters[i].initialVV[1];
            m_letters[i].VV[2 + m_letters[i].vertexIndex] = x + m_letters[i].initialVV[2];
            m_letters[i].VV[3 + m_letters[i].vertexIndex] = x + m_letters[i].initialVV[3];
        }, Vector3.zero, fadeDelay).SetEase(Ease.OutElastic).SetUpdate(UpdateType.Manual);
    }
}
