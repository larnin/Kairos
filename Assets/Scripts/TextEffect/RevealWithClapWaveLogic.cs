using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class RevealWithClapWaveLogic : BaseTextEffectLogic
{
    enum Direction {UP, DOWN, LEFT, RIGHT};

    [SerializeField] float m_delayBetweenCharacter = 0.1f;
    [SerializeField] Ease m_ease = Ease.OutQuad;
    [SerializeField] Direction direction = Direction.LEFT;

    [SerializeField] bool m_syncronised = true;

    [Sirenix.OdinInspector.HideIf("m_syncronised")]
    [SerializeField] float m_effectDuration = 0f;

    const float speedMultiplicator = 4f;

    int m_indexA = 0;
    int m_indexB = 0;

    public override void initialize(List<Letter> _letters, Transform transformText)
    {
        reset();
        m_letters = _letters;

        for (int i = 0; i < m_letters.Count; i++)
        {
            if (!m_letters[i].isVisible)
            {
                continue;
            }

            switch(direction)
            {
                case Direction.LEFT:
                    m_indexA = 3;
                    m_indexB = 2;

                    m_letters[i].VV[m_indexA + m_letters[i].vertexIndex] = m_letters[i].VV[0 + m_letters[i].vertexIndex];
                    m_letters[i].VV[m_indexB + m_letters[i].vertexIndex] = m_letters[i].VV[1 + m_letters[i].vertexIndex];
                    break;

                case Direction.RIGHT: 
                    m_indexA = 0;
                    m_indexB = 1;

                    m_letters[i].VV[m_indexA + m_letters[i].vertexIndex] = m_letters[i].VV[3 + m_letters[i].vertexIndex];
                    m_letters[i].VV[m_indexB + m_letters[i].vertexIndex] = m_letters[i].VV[2 + m_letters[i].vertexIndex];
                    break;

                case Direction.UP:
                    m_indexA = 0;
                    m_indexB = 3;

                    m_letters[i].VV[m_indexA + m_letters[i].vertexIndex] = m_letters[i].VV[1 + m_letters[i].vertexIndex];
                    m_letters[i].VV[m_indexB + m_letters[i].vertexIndex] = m_letters[i].VV[2 + m_letters[i].vertexIndex];
                    break;
                case Direction.DOWN:
                    m_indexA = 1;
                    m_indexB = 2;

                    m_letters[i].VV[m_indexA + m_letters[i].vertexIndex] = m_letters[i].VV[0 + m_letters[i].vertexIndex];
                    m_letters[i].VV[m_indexB + m_letters[i].vertexIndex] = m_letters[i].VV[3 + m_letters[i].vertexIndex];
                    break;

                 default:
                    break;
            }
        }

        if (m_syncronised != false)
        {
            m_effectDuration = 0f;
        }
    }

    public override IEnumerator run(bool canfastText) 
    {
        for (int i = 0; i < m_letters.Count; i++)
        {
            if (!m_letters[i].isVisible)
            {
                continue;
            }
            ClapWaveDotTween(i);

            if (m_action != null)
            {
                float waitValue = m_action.Invoke(i);
                if (waitValue != 0)
                {
                    yield return new WaitForSeconds(waitValue * (1f / m_localTimeScale));
                }
            }
            
            yield return new WaitForSeconds((m_delayBetweenCharacter) * (1f / m_localTimeScale));
            
        }

        yield return new WaitForSeconds((m_delayBetweenCharacter + m_effectDuration) * (1f / m_localTimeScale));
    }

    void ClapWaveDotTween(int i)
    {
        float delayUsed = m_syncronised ? m_delayBetweenCharacter : m_effectDuration;

        m_normalTween.Add(DOTween.To(() => m_letters[i].VV[m_indexA + m_letters[i].vertexIndex],
        x =>
        {
            m_letters[i].VV[m_indexA + m_letters[i].vertexIndex] = x;
        }, m_letters[i].initialVV[m_indexA], delayUsed).SetEase(m_ease));

        m_normalTween[m_normalTween.Count - 1].timeScale = m_localTimeScale;

        m_normalTween.Add(DOTween.To(() => m_letters[i].VV[m_indexB + m_letters[i].vertexIndex],
        x =>
        {
            m_letters[i].VV[m_indexB + m_letters[i].vertexIndex] = x;
        }, m_letters[i].initialVV[m_indexB], delayUsed).SetEase(m_ease));

        m_normalTween[m_normalTween.Count - 1].timeScale = m_localTimeScale;
    }
}