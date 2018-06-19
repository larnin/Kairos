using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class RevealWithFadeAndMoveLogic : BaseTextEffectLogic
{
    const float speedMultiplicator = 4f;

    [SerializeField] float m_delayBetweenCharacter = 0.1f;
    [SerializeField] float m_fadeDuration = 1f;
    [SerializeField] Ease m_fadeEase = Ease.OutQuad;

    [SerializeField] Vector3 m_startOffset = Vector3.up;
    [SerializeField] float m_moveDuration = 0.5f;
    [SerializeField] Ease m_moveEase = Ease.OutQuad;

    [SerializeField] float m_accelerationFactor = 0.05f;
    [SerializeField] float m_startSpeed = 0.5f;

    [SerializeField] bool m_LetterbyLetter = true;

    float m_currentAcceleration;

    public override void initialize(List<Letter> _letters, Transform transformText)
    {
        if(m_baseContinuous != null)
        {
            m_baseContinuous.m_tweens = m_unscaledTween;
        }

        reset();
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

            m_letters[i].position = m_startOffset;
        }

        m_currentAcceleration = m_startSpeed;
    }

    public override IEnumerator run(bool canfastText) 
    {
        keepOtherLetterInvisible(0);

        if (m_baseContinuous != null)
        {
            m_baseContinuous.globalInit(m_transformText.GetComponent<TMPro.TMP_Text>());
        }

        for (int i = 0; i < m_letters.Count; i++)
        {
            if (m_action != null)
            {
                float waitValue = m_action.Invoke(m_letters[i].index);
                if (waitValue != 0)
                {
                    yield return new WaitForSeconds(waitValue * (1f / m_localTimeScale));
                }
            }

            if (!m_letters[i].isVisible)
            {
                continue;
            }

            if(i == 2)
            {
                keepOtherLetterInvisible(i);
            }
            else if(i == 4)
            {
                keepOtherLetterInvisible(i);
            }

            m_currentLetter = i;

            FadeDotTween(i);
            
            if(m_LetterbyLetter)
                yield return new WaitForSeconds((m_delayBetweenCharacter / m_currentAcceleration) * (1f / m_localTimeScale));

            m_currentAcceleration += m_currentAcceleration * m_accelerationFactor * m_localTimeScale;
        }

        yield return new WaitForSeconds((m_fadeDuration > m_moveDuration ? m_fadeDuration : m_moveDuration) * (1f / m_localTimeScale));
    }

    void FadeDotTween(int i)
    {
        m_normalTween.Add(DOTween.ToAlpha(() => m_letters[i].VC[0 + m_letters[i].vertexIndex],
        x =>
        {
            m_letters[i].VC[0 + m_letters[i].vertexIndex] = x;
            m_letters[i].VC[1 + m_letters[i].vertexIndex] = x;
            m_letters[i].VC[2 + m_letters[i].vertexIndex] = x;
            m_letters[i].VC[3 + m_letters[i].vertexIndex] = x;
        }, 1f, m_fadeDuration / m_currentAcceleration).SetEase(m_fadeEase));

        m_normalTween[m_normalTween.Count - 1].timeScale = m_localTimeScale;

        m_normalTween.Add(DOTween.To(() => m_letters[i].position,
        x =>
        {
            m_letters[i].position = x;
            m_letters[i].VV[0 + m_letters[i].vertexIndex] = x + m_letters[i].initialVV[0];
            m_letters[i].VV[1 + m_letters[i].vertexIndex] = x + m_letters[i].initialVV[1];
            m_letters[i].VV[2 + m_letters[i].vertexIndex] = x + m_letters[i].initialVV[2];
            m_letters[i].VV[3 + m_letters[i].vertexIndex] = x + m_letters[i].initialVV[3];
        }, Vector3.zero, m_moveDuration / m_currentAcceleration).SetEase(m_moveEase));

        m_normalTween[m_normalTween.Count - 1].timeScale = m_localTimeScale;

        Tween last = m_normalTween[m_normalTween.Count - 1];

        if(m_baseContinuous != null)
        {
            last.OnComplete(() =>
            {
                applyContinuous(i);
            });
        }
    }

    void applyContinuous(int i )
    {
        m_baseContinuous.apply(m_letters[i]);
    }
}
