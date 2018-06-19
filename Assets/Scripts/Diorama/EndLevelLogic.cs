using Sirenix.Serialization;
using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class EndLevelLogic : SerializedMonoBehaviour
{
    [SerializeField] string m_nextLevelName;
    [NonSerialized, OdinSerialize]
    [SerializeField] List<DemonPhrase> m_demonPhrases = new List<DemonPhrase>();
    [SerializeField] DemonSpeaker m_demonSpeeker;

    SubscriberList m_subscriberList = new SubscriberList();
    SubscriberList m_talkSubscriberList = new SubscriberList();

    BaseTextEffectLogic m_baseEffect;

    int m_currentIndex = 0;
    List<DemonPhrase> m_currentList;

    [Serializable]
    public class Phrase
    {
        [Multiline]
        public string text;
        public BaseTextEffectLogic effect;
        public BaseDioramaAction action;
    }

    private void Awake()
    {
        m_subscriberList.Add(new Event<StartEndLevelEvent>.Subscriber(onEndLevel));
        m_talkSubscriberList.Add(new Event<DemonDoneTalkingDataEvent>.Subscriber(onTextFinished));
        m_subscriberList.Subscribe();
        m_baseEffect = Resources.Load("DataForTextEffect/normal") as BaseTextEffectLogic;
        m_currentList = m_demonPhrases;
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
        m_talkSubscriberList.Unsubscribe();
    }

    void sayCurrentMessage()
    {
        if(m_currentIndex >= m_currentList.Count)
        {
            jumpToNextLevel();
            return;
        }

        var dp = m_currentList[m_currentIndex];

        Event<DemonSpeakDataEvent>.Broadcast(new DemonSpeakDataEvent(dp, m_baseEffect));
    }

    void jumpToNextLevel()
    {
        m_talkSubscriberList.Unsubscribe();
        SceneSystem.changeScene(m_nextLevelName);
    }

    void onEndLevel(StartEndLevelEvent e)
    {
        Event<LockPlayerControlesEvent>.Broadcast(new LockPlayerControlesEvent(true));

        m_talkSubscriberList.Subscribe();

        m_currentIndex = 0;

        if(m_demonSpeeker != null)
		    m_demonSpeeker.gameObject.SetActive(true);

        sayCurrentMessage();
    }

    void onTextFinished(DemonDoneTalkingDataEvent e)
    {
        if(e.indexOfAnswer >= 0)
        {
            m_currentList = m_currentList[m_currentIndex].playerChoices[e.indexOfAnswer].DemonPhraseSayAfter;
            m_currentIndex = 0;
        }
        else m_currentIndex++;

        sayCurrentMessage();
    }
}