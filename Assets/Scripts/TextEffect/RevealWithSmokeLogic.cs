using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class RevealWithSmokeLogic : BaseTextEffectLogic
{
    [SerializeField] float m_delayBetweenCharacter = 0.05f;
    [SerializeField] float m_fadeDuration = 0.5f;
    [SerializeField] float m_delayAtTheEnd = 1.0f;


    [SerializeField] GameObject m_smoke;
    [SerializeField] Ease m_fadeEase = Ease.OutQuad;
    
    const float speedMultiplicator = 4f;

    public override void initialize(List<Letter> _letters, Transform transformText)
    {
        m_letters = _letters;
        m_transformText = transformText;

        for (int i = 0; i < m_letters.Count; i++)
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

    public override IEnumerator run(bool canfastText) 
    {
        for (int i = 0; i < m_letters.Count; i++)
        {
            if (m_action != null)
            {
                float waitValue = m_action.Invoke(i);
                if (waitValue != 0)
                {
                    yield return new WaitForSeconds(waitValue * (1f / m_localTimeScale));
                }
            }

            if (!m_letters[i].isVisible)
            {
                continue;
            }
            SmokeAppear(i);

            Vector3 middlePoint = (m_letters[i].VV[0 + m_letters[i].vertexIndex] +
            m_letters[i].VV[1 + m_letters[i].vertexIndex] +
            m_letters[i].VV[2 + m_letters[i].vertexIndex] +
            m_letters[i].VV[3 + m_letters[i].vertexIndex] ) / 4f;
            middlePoint = m_transformText.TransformPoint(middlePoint); 

            Instantiate(m_smoke, middlePoint, Quaternion.identity);

            yield return new WaitForSeconds((m_delayBetweenCharacter) * (1f / m_localTimeScale));
        }

        yield return new WaitForSeconds((m_delayBetweenCharacter + m_fadeDuration + m_delayAtTheEnd ) * (1f / m_localTimeScale));
    }

    void SmokeAppear(int i)
    {
        m_normalTween.Add( DOTween.ToAlpha(() => m_letters[i].VC[0 + m_letters[i].vertexIndex],
        x =>
        {
            m_letters[i].VC[0 + m_letters[i].vertexIndex] = x;
            m_letters[i].VC[1 + m_letters[i].vertexIndex] = x;
            m_letters[i].VC[2 + m_letters[i].vertexIndex] = x;
            m_letters[i].VC[3 + m_letters[i].vertexIndex] = x;
        }, 1f, m_fadeDuration).SetEase(m_fadeEase));
    }
}
 