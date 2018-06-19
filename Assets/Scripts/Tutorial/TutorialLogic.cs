using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;
using Sirenix.OdinInspector;
using System.Reflection;
using DG.Tweening;

public class TutorialLogic : MonoBehaviour
{
    [Serializable]
    class MessageData
    {
        [Multiline]
        public string message;
        public bool waitNextEvent;
        [HideIf("waitNextEvent")]
        public float messageDuration = 4;
        public float messageDelay = 1;
    }

    [Serializable]
    class TutorialChunk
    {
        public List<GameObject> disableObjects = new List<GameObject>();
        public List<GameObject> enableObjects = new List<GameObject>();
        public List<MessageData> messages = new List<MessageData>();
        //public string eventName = "";
        public EventType eventType;
    }

    enum EventType
    {
        WaitTextEnd,
        FocusEvent,
        HoverObjectWithDemonEvent,
        InteractObjectWithDemonEvent,
        DemonDoneTalkingDataEvent,
        StartDemonTextWithChoiceEvent,
        UpdateAdaptiveUIDataEvent,
        DialongWithDemonEnd,
        TimelineRewindEvent,
        TimelinePauseEvent,
        TimelineFastForwardEvent,
        PauseEvent,
        ShowControlesEvent,
        MoveEvent,
    }

    [SerializeField] List<TutorialChunk> m_tutorial;
    [SerializeField] float m_messageFadeTime = 1;

    int m_currentIndex = -1;
    SubscriberList m_tutoSubscriberList = new SubscriberList();
    SubscriberList m_subscriberList = new SubscriberList();
    
    void Start()
    {
        if (SaveAttributes.getTutoFinished())
        {
            gameObject.SetActive(false);
            return;
        }
        DOVirtual.DelayedCall(0.01f, () => startNext());

        m_subscriberList.Add(new Event<StopTutoEvent>.Subscriber(onStopTuto));
        m_subscriberList.Subscribe();
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
        m_tutoSubscriberList.Unsubscribe();
    }

    void startNext()
    {
        m_tutoSubscriberList.Unsubscribe();
        m_tutoSubscriberList.Clear();

        m_currentIndex++;

        Event<StopTutorialTextEvent>.Broadcast(new StopTutorialTextEvent());

        if (m_currentIndex >= m_tutorial.Count)
        {
            stopTutorial();
            return;
        }

        createConnexion(m_tutorial[m_currentIndex].eventType);
        m_tutoSubscriberList.Subscribe();

        disableElements(m_tutorial[m_currentIndex].disableObjects);
        enableElements(m_tutorial[m_currentIndex].enableObjects);
        showText(m_currentIndex, 0);

    }

    void stopTutorial()
    {
        SaveAttributes.setTutoFinished(true);
        gameObject.SetActive(false);
    }

    void createConnexion(string eventName)
    {
        Type t = Type.GetType(eventName);
        if (t == null)
        {
            Debug.LogError("Can't find the event type " + eventName);
            return;
        }
        Type eventType = typeof(Event<>);
        var s = eventType.MakeGenericType(new Type[] { t }).GetNestedType("Subscriber");

        var m = typeof(TutorialLogic).GetMethod("onEvent", BindingFlags.NonPublic | BindingFlags.Instance);
        var genericM = m.MakeGenericMethod(new Type[] { t });

        var action = typeof(Action<>).MakeGenericType(new Type[] { t });

        m_tutoSubscriberList.Add((IEventSubscriber)s.GetConstructors()[0].Invoke(new object[] { Delegate.CreateDelegate(action, this, genericM) }));
    }

    void createConnexion(EventType type)
    {
        switch (type)
        {
            case EventType.FocusEvent:
                m_tutoSubscriberList.Add(new Event<FocusEvent>.Subscriber(onEvent));
                break;
            case EventType.HoverObjectWithDemonEvent:
                m_tutoSubscriberList.Add(new Event<HoverObjectWithDemonEvent>.Subscriber(onEvent));
                break;
            case EventType.InteractObjectWithDemonEvent:
                m_tutoSubscriberList.Add(new Event<InteractObjectWithDemonEvent>.Subscriber(onEvent));
                break;
            case EventType.DemonDoneTalkingDataEvent:
                m_tutoSubscriberList.Add(new Event<DemonDoneTalkingDataEvent>.Subscriber(onEvent));
                break;
            case EventType.StartDemonTextWithChoiceEvent:
                m_tutoSubscriberList.Add(new Event<StartDemonTextWithChoiceEvent>.Subscriber(onEvent));
                break;
            case EventType.UpdateAdaptiveUIDataEvent:
                m_tutoSubscriberList.Add(new Event<UpdateAdaptiveUIDataEvent>.Subscriber(onEvent));
                break;
            case EventType.DialongWithDemonEnd:
                m_tutoSubscriberList.Add(new Event<DialongWithDemonEnd>.Subscriber(onEvent));
                break;
            case EventType.TimelineRewindEvent:
                m_tutoSubscriberList.Add(new Event<TimelineRewindEvent>.Subscriber(onEvent));
                break;
            case EventType.TimelinePauseEvent:
                m_tutoSubscriberList.Add(new Event<TimelinePauseEvent>.Subscriber(onEvent));
                break;
            case EventType.TimelineFastForwardEvent:
                m_tutoSubscriberList.Add(new Event<TimelineFastForwardEvent>.Subscriber(onEvent));
                break;
            case EventType.PauseEvent:
                m_tutoSubscriberList.Add(new Event<PauseEvent>.Subscriber(onEvent));
                break;
            case EventType.ShowControlesEvent:
                m_tutoSubscriberList.Add(new Event<ShowControlesEvent>.Subscriber(onEvent));
                break;
            case EventType.MoveEvent:
                m_tutoSubscriberList.Add(new Event<PlayerMovedEvent>.Subscriber(onEvent));
                break;
        }  
    }

    void disableElements(List<GameObject> obj)
    {
        foreach (var o in obj)
            o.SetActive(false);
    }

    void enableElements(List<GameObject> obj)
    {
        foreach (var o in obj)
            o.SetActive(true);
    }

    void showText(int index, int messageIndex)
    {
        if (index != m_currentIndex)
            return;

        if (m_tutorial[index].messages.Count <= messageIndex)
        {
            if (m_tutorial[index].eventType == EventType.WaitTextEnd)
                startNext();
            return;
        }

        DOVirtual.DelayedCall(m_tutorial[index].messages[messageIndex].messageDelay, () => onShowText(index, messageIndex));
    }

    void onShowText(int index, int messageIndex)
    {
        if (index != m_currentIndex)
            return;

        var t = m_tutorial[index].messages[messageIndex];
        if (t.waitNextEvent)
            Event<ShowTutorialTextEvent>.Broadcast(new ShowTutorialTextEvent(m_messageFadeTime, t.message));
        else Event<ShowTutorialTextEvent>.Broadcast(new ShowTutorialTextEvent(m_messageFadeTime, t.messageDuration, t.message));

        DOVirtual.DelayedCall(t.messageDuration, () => showText(index, messageIndex+1));
    }

    void onEvent<T>(T e) where T : EventArgs
    {
        if(typeof(T) == typeof(TimelineRewindEvent))
        {
            DOVirtual.DelayedCall(0.01f, () =>
            {
                rebuildNavMesh();
            });
        }

        startNext();
    }

    void onStopTuto(StopTutoEvent e)
    {
        while (m_currentIndex < m_tutorial.Count)
            startNext();
    }

    void rebuildNavMesh()
    {
        Event<RebuildNavmeshEvent>.Broadcast(new RebuildNavmeshEvent());
    }
}