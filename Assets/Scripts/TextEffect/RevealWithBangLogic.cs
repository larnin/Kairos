using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class RevealWithBangLogic : BaseTextEffectLogic
{
    [SerializeField] float m_delayBetweenCharacter = 0.1f;
    [SerializeField] float m_maxSize = 2f;
    [SerializeField] float m_goToMaxDelay = 1f;
    [SerializeField] Ease m_goToMaxEase = Ease.OutQuad;

    [SerializeField] float delayBetween = 0f;

    [SerializeField] float m_goToNormalDelay = 0.5f;
    [SerializeField] Ease m_goToNormalEase = Ease.OutQuad;

    [SerializeField] bool m_allAtTheSameTime = false;

    const float speedMultiplicator = 4f;

    public override void initialize(List<Letter> _letters,Transform transformText)
    {
        reset();
        m_letters = _letters;
        
        for (int i = 0; i < m_letters.Count; i++)
        {
            if (!m_letters[i].isVisible)
            {
                continue;
            }

            Vector3 middlePoint = (m_letters[i].VV[0 + m_letters[i].vertexIndex] +
                                  m_letters[i].VV[1 + m_letters[i].vertexIndex] +
                                  m_letters[i].VV[2 + m_letters[i].vertexIndex] +
                                  m_letters[i].VV[3 + m_letters[i].vertexIndex]) / 4f;

            m_letters[i].VV[0 + m_letters[i].vertexIndex] = middlePoint;
            m_letters[i].VV[1 + m_letters[i].vertexIndex] = middlePoint;
            m_letters[i].VV[2 + m_letters[i].vertexIndex] = middlePoint;
            m_letters[i].VV[3 + m_letters[i].vertexIndex] = middlePoint;
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
            BangDotTween(i);

            if (m_action != null)
            {
                float waitValue = m_action.Invoke(i);
                if (waitValue != 0)
                {
                    yield return new WaitForSeconds(waitValue * (1 / m_localTimeScale));
                }
            }

            if(!m_allAtTheSameTime)
            {
                yield return new WaitForSeconds((m_delayBetweenCharacter) * (1 / m_localTimeScale));
            }
        }

        yield return new WaitForSeconds((m_goToMaxDelay + m_goToNormalDelay) * (1 / m_localTimeScale));
    }

    void BangDotTween(int i)
    {
        Vector3 direction0 = m_letters[i].initialVV[0] - m_letters[i].VV[0 + m_letters[i].vertexIndex];
        Vector3 direction1 = m_letters[i].initialVV[1] - m_letters[i].VV[1 + m_letters[i].vertexIndex];
        Vector3 direction2 = m_letters[i].initialVV[2] - m_letters[i].VV[2 + m_letters[i].vertexIndex];
        Vector3 direction3 = m_letters[i].initialVV[3] - m_letters[i].VV[3 + m_letters[i].vertexIndex];

        Vector3 newPos0 = m_letters[i].VV[0 + m_letters[i].vertexIndex] + direction0 * m_maxSize;
        Vector3 newPos1 = m_letters[i].VV[1 + m_letters[i].vertexIndex] + direction1 * m_maxSize;
        Vector3 newPos2 = m_letters[i].VV[2 + m_letters[i].vertexIndex] + direction2 * m_maxSize;
        Vector3 newPos3 = m_letters[i].VV[3 + m_letters[i].vertexIndex] + direction3 * m_maxSize;

        // 111111111111111111111111
        m_normalTween.Add(DOTween.To(() => m_letters[i].VV[0 + m_letters[i].vertexIndex],
        x =>
        {
            m_letters[i].VV[0 + m_letters[i].vertexIndex] = x;
        }, newPos0, m_goToMaxDelay).SetEase(m_goToMaxEase).OnComplete(
            () =>
            {
                // Normal !
                m_normalTween.Add( DOTween.To(() => m_letters[i].VV[0 + m_letters[i].vertexIndex],
                x =>
                {
                    m_letters[i].VV[0 + m_letters[i].vertexIndex] = x;
                }, m_letters[i].initialVV[0], m_goToNormalDelay).SetEase(m_goToNormalEase).SetDelay(delayBetween) );

                m_normalTween[m_normalTween.Count - 1].timeScale = m_localTimeScale;

            }));

        m_normalTween[m_normalTween.Count - 1].timeScale = m_localTimeScale;

        // 222222222222222222222222222
        m_normalTween.Add(DOTween.To(() => m_letters[i].VV[1 + m_letters[i].vertexIndex],
        x =>
        {
            m_letters[i].VV[1 + m_letters[i].vertexIndex] = x;
        }, newPos1, m_goToMaxDelay).SetEase(m_goToMaxEase).OnComplete(() => 
        {
            // normal
            m_normalTween.Add( DOTween.To(() => m_letters[i].VV[1 + m_letters[i].vertexIndex],
            x =>
            {
                m_letters[i].VV[1 + m_letters[i].vertexIndex] = x;
            }, m_letters[i].initialVV[1], m_goToNormalDelay).SetEase(m_goToNormalEase).SetDelay(delayBetween) );

            m_normalTween[m_normalTween.Count - 1].timeScale = m_localTimeScale;
        }));

        m_normalTween[m_normalTween.Count - 1].timeScale = m_localTimeScale;

        // 3333333333333333333333333333333333333
        m_normalTween.Add(DOTween.To(() => m_letters[i].VV[2 + m_letters[i].vertexIndex],
        x =>
        {
            m_letters[i].VV[2 + m_letters[i].vertexIndex] = x;
        }, newPos2, m_goToMaxDelay).SetEase(m_goToMaxEase).OnComplete(() => {

            m_normalTween.Add(DOTween.To(() => m_letters[i].VV[2 + m_letters[i].vertexIndex],
            x =>
            {
                // normal
                m_letters[i].VV[2 + m_letters[i].vertexIndex] = x;
            }, m_letters[i].initialVV[2], m_goToNormalDelay).SetEase(m_goToNormalEase).SetDelay(delayBetween));

            m_normalTween[m_normalTween.Count - 1].timeScale = m_localTimeScale;
        }));

        m_normalTween[m_normalTween.Count - 1].timeScale = m_localTimeScale;

        // 444444444444444444444444444444444444
        m_normalTween.Add(DOTween.To(() => m_letters[i].VV[3 + m_letters[i].vertexIndex],
        x =>
        {
            m_letters[i].VV[3 + m_letters[i].vertexIndex] = x;
        }, newPos3, m_goToMaxDelay).SetEase(m_goToMaxEase).OnComplete(() => 
        {
            // normal
            m_normalTween.Add(DOTween.To(() => m_letters[i].VV[3 + m_letters[i].vertexIndex],
            x =>
            {
                m_letters[i].VV[3 + m_letters[i].vertexIndex] = x;
            }, m_letters[i].initialVV[3], m_goToNormalDelay).SetEase(m_goToNormalEase).SetDelay(delayBetween));

            m_normalTween[m_normalTween.Count - 1].timeScale = m_localTimeScale;
        }));

        m_normalTween[m_normalTween.Count - 1].timeScale = m_localTimeScale;
    }
}