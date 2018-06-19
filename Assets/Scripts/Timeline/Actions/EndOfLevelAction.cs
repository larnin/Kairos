using Sirenix.OdinInspector;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class EndOfLevelAction : BaseAction
{
    public override void trigger(GameObject obj)
    {
        Event<StartEndLevelEvent>.Broadcast(new StartEndLevelEvent());
    }

    /*const int animationID = 777;

    [SerializeField] Animator m_demonAnimator;
    [SerializeField] string m_animTrigger;

    [SerializeField] float m_delayAfterActivation = 0f;
    [SerializeField] string m_sceneNameToLoad = "";

    //[OnInspectorGUI("onDemonParamChanged")]
    [SerializeField] List<string> m_phraseToSay = new List<string>();
    //[OnInspectorGUI("onDemonParamChanged")]
    [SerializeField] List<BaseTextEffectLogic> m_baseTextEffect = new List<BaseTextEffectLogic>();

	public override void trigger(GameObject obj)
	{
        UnityEngine.SceneManagement.SceneManager.LoadScene(m_sceneNameToLoad);
      //  obj.GetComponent<DemonSpeaker>().StartCoroutine(endAnimationEffect(obj));
    }

    IEnumerator endAnimationEffect(GameObject obj)
    {
        m_demonAnimator.SetTrigger(m_animTrigger);

        if (m_delayAfterActivation != 0)
        {
            yield return new WaitForSeconds(m_delayAfterActivation);
        }

        obj.SetActive(true);
        Event<LockPlayerControlesEvent>.Broadcast(new LockPlayerControlesEvent(true));
        yield return null;
        Event<LockPlayerControlesEvent>.Broadcast(new LockPlayerControlesEvent(true));
        
        Event<DemonSpeakDataForTheEndEvent>.Broadcast(new DemonSpeakDataForTheEndEvent(m_phraseToSay, m_baseTextEffect, m_sceneNameToLoad));
    }
    

    // qualityOfLife imrovment 
    [OnInspectorGUI]
    void onDemonParamChanged()
    {
        if(m_phraseToSay != null)
        {
            if (m_baseTextEffect == null)
                m_baseTextEffect = new List<BaseTextEffectLogic>();

            BaseTextEffectLogic normal = null;
            if (m_phraseToSay.Count > m_baseTextEffect.Count)
            {
                normal = Resources.Load("DataForTextEffect/normal") as BaseTextEffectLogic;
                int nb = m_phraseToSay.Count - m_baseTextEffect.Count;

                for (int i = 0; i < nb; i++)
                    m_baseTextEffect.Add(normal);
            }

            if(normal ==null)
                normal = Resources.Load("DataForTextEffect/normal") as BaseTextEffectLogic;

            for(int i = 0; i < m_baseTextEffect.Count; i++)
            {
                if(m_baseTextEffect[i] == null)
                {
                    m_baseTextEffect[i] = normal;
                }
            }
        }
    }*/
}
