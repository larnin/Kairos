using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.Playables;
using DG.Tweening;

public class TimelineRewindLogic : MonoBehaviour
{
    const string rewindAxis = "BackToPreviousTimeline";

    const float m_timeEffect = 2f;

    bool m_locked = false;
    bool m_rewindPressed = false;

    bool p_canRewind = true;

    SubscriberList m_subscriberList = new SubscriberList();

    private void Awake()
    {
        m_subscriberList.Add(new Event<LockPlayerControlesEvent>.Subscriber(onLockControls));
        m_subscriberList.Subscribe();
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    private void Update()
    {
        if (m_locked)
            return;
        
        if (Input.GetAxis(rewindAxis) > 0.5f && !m_rewindPressed)
        {
            m_rewindPressed = true;
            Event<TimelineRewindEventBefore>.Broadcast(new TimelineRewindEventBefore());
            Event<TimelineRewindEvent>.Broadcast(new TimelineRewindEvent());
        }
        if (Input.GetAxis(rewindAxis) < 0.5f)
            m_rewindPressed = false;
	}

    void onLockControls(LockPlayerControlesEvent e)
    {
        m_locked = e.locked;
    }
    
}