using DG.Tweening;
using Sirenix.OdinInspector;
using Sirenix.Serialization;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ShowOdinSerializedPropertiesInInspector]
class ObjectWithTheDemon2Logic : InteractableLogic, ISerializationCallbackReceiver, ISupportsPrefabSerialization
{
    const int noChoice = -1;

    [SerializeField] DemonSpeaker m_demonText = null;
    [SerializeField] BaseTextEffectLogic m_textEffectForDemonSpeak = null;

    [NonSerialized, OdinSerialize]
    List<DemonPhrase> m_demonPhrases = new List<DemonPhrase>();

    SubscriberList m_subscriberList = new SubscriberList();
    SubscriberList m_deadEndSubscriverList = new SubscriberList();
    DemonObjectFeedback m_demonObjectFeedback = null;

    bool m_noInput = false;
    bool m_menuChoiceOpen = false;

    int m_currentDemonPhraseIndex = 0;
    List<DemonPhrase> m_currentDemonPhrasesList = null;
    
    // odin reimplation 
    [SerializeField, HideInInspector]
    private SerializationData serializationData;

    SerializationData ISupportsPrefabSerialization.SerializationData { get { return this.serializationData; } set { this.serializationData = value; } }

    void ISerializationCallbackReceiver.OnAfterDeserialize()
    {
        UnitySerializationUtility.DeserializeUnityObject(this, ref this.serializationData);
    }

    void ISerializationCallbackReceiver.OnBeforeSerialize()
    {
        UnitySerializationUtility.SerializeUnityObject(this, ref this.serializationData);
    }
    //------

    void Start()
    {
        m_subscriberList.Add(new Event<DemonDoneTalkingDataEvent>.Subscriber(demonDoneTalking));

        m_deadEndSubscriverList.Add(new Event<TimelineDeadEndEvent>.Subscriber(onDeadEnd));
        m_deadEndSubscriverList.Add(new Event<TimelineRewindEvent>.Subscriber(onRewind));
        m_deadEndSubscriverList.Subscribe();
    }
    
    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
        m_deadEndSubscriverList.Unsubscribe();
    }

    protected override void onEnable()
    {
        FocusEffectLogic.registerInteractable(gameObject);
        m_demonObjectFeedback = GetComponentInChildren<DemonObjectFeedback>();
    }

    protected override void onDisable()
    {
        FocusEffectLogic.unregisterInteractable(gameObject);
    }

    private void makeConversation()
    {
        if(m_currentDemonPhrasesList.Count > m_currentDemonPhraseIndex)
        {
            DemonPhrase demonPhrase = m_currentDemonPhrasesList[m_currentDemonPhraseIndex];
			BaseTextEffectLogic textEffectToUse = m_textEffectForDemonSpeak;
			if (demonPhrase.hasDifferentEffect) textEffectToUse = demonPhrase.m_textEffectForDemonSpeak;
            Event<DemonSpeakDataEvent>.Broadcast(new DemonSpeakDataEvent(demonPhrase, textEffectToUse));
			if (demonPhrase.dioramaAction != null)
				demonPhrase.dioramaAction.triggerBegin();
        }
        else
        {
            quit();
        }
    }

    private void init()
    {
        
        if(m_demonText.gameObject.activeSelf == false)
        {
            m_demonText.gameObject.SetActive(true);
            m_subscriberList.Subscribe();
        }

        
        Event<LockPlayerControlesEvent>.Broadcast(new LockPlayerControlesEvent(true));
        m_noInput = true;
        m_currentDemonPhrasesList = m_demonPhrases;
        m_currentDemonPhraseIndex = 0;
    }

    private void quit()
    {
        m_currentDemonPhraseIndex = 0;
        m_currentDemonPhrasesList = m_demonPhrases;

        Event<DemonSpeakDataEvent>.Broadcast(null);
        Event<LockPlayerControlesEvent>.Broadcast(new LockPlayerControlesEvent(false));
        Event<DialongWithDemonEnd>.Broadcast(new DialongWithDemonEnd());
        m_noInput = false;

        m_demonText.gameObject.SetActive(false);
        m_subscriberList.Unsubscribe();
        m_demonObjectFeedback.hover(false);
    }
    
    void demonDoneTalking(DemonDoneTalkingDataEvent answerNumber)
    {
        if(m_currentDemonPhraseIndex < 0  || m_currentDemonPhraseIndex >= m_currentDemonPhrasesList.Count)
        {
            quit();
            return;
        }


        DemonPhrase demonPhrase = m_currentDemonPhrasesList[m_currentDemonPhraseIndex];
        if(demonPhrase != null)
        {
            if (demonPhrase.dioramaAction != null)
            {
                demonPhrase.dioramaAction.triggerEnd();
            }

            if (demonPhrase.hasChoice)
            {
                if (answerNumber.indexOfAnswer == noChoice)
                {
                    m_currentDemonPhraseIndex++;
                    if (m_currentDemonPhrasesList.Count != m_currentDemonPhraseIndex)
                    {
                        makeConversation();
                    }
                    else
                    {
                        quit();
                    }
                }
                else
                {
                    // change de "list" de phrase
                    m_currentDemonPhraseIndex = 0;
                    m_currentDemonPhrasesList = demonPhrase.playerChoices[answerNumber.indexOfAnswer].DemonPhraseSayAfter;
                    if (m_currentDemonPhrasesList != null)
                    {
                        makeConversation();
                    }
                    else
                    {
                        quit();
                    }
                    
                }
            }
            else
            {
                m_currentDemonPhraseIndex++;
                if (m_currentDemonPhrasesList.Count != m_currentDemonPhraseIndex)
                {
                    makeConversation();
                }
                else
                {
                    quit();
                }
            }
        }
        else
        {
            quit();
        }
    }

    public override void onInteraction()
    {
        if (!m_menuChoiceOpen && !m_noInput)
        {
            Event<StartDemonTextInteractionEvent>.Broadcast(new StartDemonTextInteractionEvent());
            Event<InteractObjectWithDemonEvent>.Broadcast(new InteractObjectWithDemonEvent());
            init();
			m_demonText.makeDemonSpeak();
			makeConversation();
        }
    }
    
    public override void onHoverStart()
    {
        m_demonText.gameObject.SetActive(true);
        m_subscriberList.Subscribe();
        m_demonObjectFeedback.hover(true);

        Event<HoverObjectWithDemonEvent>.Broadcast(new HoverObjectWithDemonEvent());
    }

    public override void onHoverEnd()
    {
        if(m_noInput == false)
        {
            m_demonObjectFeedback = GetComponentInChildren<DemonObjectFeedback>();
            m_demonText.gameObject.SetActive(false);
            m_subscriberList.Unsubscribe();
            m_demonObjectFeedback.hover(false);
        }
    }

    public void onDeadEnd(TimelineDeadEndEvent e)
    {
        FocusEffectLogic.unregisterInteractable(gameObject);
    }

    public void onRewind(TimelineRewindEvent e)
    {
        if (gameObject.activeInHierarchy)
        {
            FocusEffectLogic.registerInteractable(gameObject);
            m_noInput = false;
            m_currentDemonPhrasesList = m_demonPhrases;
            m_currentDemonPhraseIndex = 0;
        }
    }
}