using Sirenix.OdinInspector;
using Sirenix.Serialization;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class BackforwardDiscutionLogic : SerializedMonoBehaviour
{
    [NonSerialized, OdinSerialize]
    [SerializeField] List<DemonPhrase> m_demonPhrases = new List<DemonPhrase>();
    [SerializeField] DemonSpeaker m_speaker;
    
    BaseTextEffectLogic m_baseEffect;
    int m_currentIndex = 0;
    List<DemonPhrase> m_currentList;

    SubscriberList m_talkSubscriberList = new SubscriberList();

    private void Awake()
    {
        m_talkSubscriberList.Add(new Event<DemonDoneTalkingDataEvent>.Subscriber(onTextFinished));
        m_baseEffect = Resources.Load("DataForTextEffect/normal") as BaseTextEffectLogic;
    }

    private void OnDestroy()
    {
        m_talkSubscriberList.Unsubscribe();
    }

    public void startText()
    {
        m_talkSubscriberList.Subscribe();
        m_currentList = m_demonPhrases;
        m_currentIndex = 0;
        m_speaker.gameObject.SetActive(true);
        sayCurrentMessage();
    }

    void sayCurrentMessage()
    {
        if (m_currentIndex >= m_currentList.Count)
        {
            execEnd();
            return;
        }
        
        DemonPhrase dp = m_demonPhrases[m_currentIndex];

        Event<DemonSpeakDataEvent>.Broadcast(new DemonSpeakDataEvent(dp, m_baseEffect));
    }

    void execEnd()
    {
        m_talkSubscriberList.Unsubscribe();
        Event<DemonSpeakDataEvent>.Broadcast(null);
        m_speaker.gameObject.SetActive(false);
        Event<DialongWithDemonEnd>.Broadcast(new DialongWithDemonEnd());
    }

    void onTextFinished(DemonDoneTalkingDataEvent e)
    {
        if (e.indexOfAnswer >= 0)
        {
            m_currentList = m_currentList[m_currentIndex].playerChoices[e.indexOfAnswer].DemonPhraseSayAfter;
            m_currentIndex = 0;
        }
        else m_currentIndex++;

        sayCurrentMessage();
    }
}
