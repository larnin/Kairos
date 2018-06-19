using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class RevealWithSmoothFadeTexturedLogic : BaseTextEffectLogic
{
    [SerializeField] float m_delayBetweenCharacter = 0.05f;
    [SerializeField] float m_speed = 2f;
    
    const float speedMultiplicator = 4f;

    public override void initialize(List<Letter> _letters, Transform transformText)
    {
        m_letters = _letters;
        m_transformText = transformText;

        TMPro.TMP_Text textPro = m_transformText.GetComponent<TMPro.TMP_Text>();
        
        
        for (int i = 0; i < m_letters.Count; i++)
        {


            if (!m_letters[i].isVisible)
            {
                continue;
            }



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

            if(m_action != null)
            {
               float waitValue = m_action.Invoke(i);
               if(waitValue != 0)
                {
                    yield return new WaitForSeconds(waitValue * (1f / m_localTimeScale));
                }
            }

            yield return new WaitForSeconds((m_delayBetweenCharacter) * (1f / m_localTimeScale));
        }

        yield return new WaitForSeconds(m_delayBetweenCharacter * (1f / m_localTimeScale));
    }
}
