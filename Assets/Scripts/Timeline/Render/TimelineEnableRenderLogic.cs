using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using DG.Tweening;


public class TimelineEnableRenderLogic : MonoBehaviour
{
    [SerializeField] float m_enableTime = 2;

    SubscriberList m_subscriberList = new SubscriberList();

    bool m_FastForward = false;
    float m_currentEnableTime = 0;

    private void Awake()
    {
        m_subscriberList.Add(new Event<TimelineFastForwardEvent>.Subscriber(onFastForward));
        m_subscriberList.Add(new Event<TimelinePropertiesChangedEvent>.Subscriber(onPropertyChange));
        m_subscriberList.Add(new Event<TimelinePauseEvent>.Subscriber(onTimelinePause));
        m_subscriberList.Add(new Event<TimelineStopEvent>.Subscriber(onTimelineStop));
        m_subscriberList.Add(new Event<UpdateCurrentTimelineIndexEvent>.Subscriber(onUpdateTimeline));
        m_subscriberList.Subscribe();
    }

    private void Start()
    {
        gameObject.SetActive(false);
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    private void Update()
    {
        if (!m_FastForward)
        {
            m_currentEnableTime -= Time.deltaTime;
            if (m_currentEnableTime <= 0)
                gameObject.SetActive(false);
        }
    }

    void onFastForward(TimelineFastForwardEvent e)
    {
        m_FastForward = e.started;
        m_currentEnableTime = m_enableTime;
        gameObject.SetActive(true);
    }

    void onPropertyChange(TimelinePropertiesChangedEvent e)
    {
        m_currentEnableTime = m_enableTime;
        gameObject.SetActive(true);
    }

    void onTimelinePause(TimelinePauseEvent e)
    {
        m_currentEnableTime = m_enableTime;
        gameObject.SetActive(true);
    }

    void onTimelineStop(TimelineStopEvent e)
    {
        m_currentEnableTime = m_enableTime;
        gameObject.SetActive(true);
    }

    void onUpdateTimeline(UpdateCurrentTimelineIndexEvent e)
    {
        m_currentEnableTime = m_enableTime;
        gameObject.SetActive(true);
    }
}
