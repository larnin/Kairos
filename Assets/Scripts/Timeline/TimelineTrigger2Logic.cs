using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine.Playables;

public class TimelineTrigger2Logic : TriggerBaseLogic
{
    const string playButtonName = "TimelinePlayPause";
    const string stopButtonName = "TimelineStop";
    const float fastForwardDelay = 0.5f;
    const float fastForwardSpeed = 10.0f;
    const float rewindSpeed = -5.0f;
    const string pauseName = "pause";
    const string pauseEventName = "pauseEvent";
    const string pauseTimelineEventName = "pauseTimeline";
    const string lockControlsEventName = "lockControls";

    bool m_onFastForward = false;
    bool m_onFastForwardForward = false;
    bool m_enabled = false;
    float m_fastForwardPressTime;

    float m_currentTime = 0;

    PauseList m_pauseList = new PauseList();
    SubscriberList m_subscriberList = new SubscriberList();

    PlayableDirector m_director;

    class PauseList
    {
        Dictionary<string, bool> m_pauses = new Dictionary<string, bool>();

        public void set(string key, bool value)
        {
            m_pauses[key] = value;
        }

        public bool get(string key)
        {
            if (!m_pauses.ContainsKey(key))
                return false;
            return m_pauses[key];
        }

        public bool get()
        {
            foreach (var it in m_pauses)
            {
                if (it.Value)
                    return true;
            }
            return false;
        }
    }

    private void Awake()
    {
        m_pauseList.set(pauseName, true);
        m_enabled = false;

        m_director = GetComponent<PlayableDirector>();
        m_director.timeUpdateMode = DirectorUpdateMode.Manual;
        m_director.Stop();

        m_subscriberList.Add(new Event<PauseEvent>.Subscriber(onPause));
        m_subscriberList.Add(new Event<PauseTimelineEvent>.Subscriber(onPauseTimeline));
        m_subscriberList.Add(new Event<LockPlayerControlesEvent>.Subscriber(onLockControls));
        m_subscriberList.Add(new Event<RestartTimelineEvent>.Subscriber(onRestartTimeline));
        m_subscriberList.Subscribe();
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }
    
    private void Update()
    {
        if (Input.GetButtonUp(playButtonName) && !m_onFastForward)
            playPauseAction();

        updateFastForward();

        run();
    }

    public override void onEnter(TriggerInteractionLogic entity)
    {
        m_enabled = true;
        play(pauseName);
    }

    public override void onExit(TriggerInteractionLogic entity)
    {
        stop();
        m_enabled = false;
    }

    void updateFastForward()
    {
        if (!m_enabled)
            return;

        if(m_pauseList.get(pauseName) && m_onFastForward)
            play(pauseName);
        if (m_pauseList.get(lockControlsEventName) && !m_onFastForward)
            return;
        if(m_pauseList.get() && m_onFastForward)
        {
            m_onFastForward = false;
            send(new TimelineFastForwardEvent(false, m_onFastForwardForward));
        }

        if(Input.GetButton(playButtonName))
        {
            m_fastForwardPressTime += Time.deltaTime;
            if(m_fastForwardPressTime > fastForwardDelay && ! m_onFastForward)
            {
                m_onFastForward = true;
                m_onFastForwardForward = true;
                send(new TimelineFastForwardEvent(true, true));
            }

            if(m_onFastForward && !m_onFastForwardForward)
            {
                m_onFastForwardForward = true;
                send(new TimelineFastForwardEvent(true, true));
            }
        }
        else if(Input.GetButton(stopButtonName))
        {
            if(!m_onFastForward || m_onFastForwardForward)
            {
                m_onFastForward = true;
                m_onFastForwardForward = false;
                send(new TimelineFastForwardEvent(true, false));
            }
        }
        else
        {
            m_fastForwardPressTime = 0;
            if (m_onFastForward)
                send(new TimelineFastForwardEvent(false, m_onFastForwardForward));
            m_onFastForward = false;
        }
    }

    void playPauseAction()
    {
        if (!m_enabled)
        {
             if(!m_pauseList.get(pauseName))
                pause(pauseName);
            return;
        }

        if (m_onFastForward)
            return;

        if (m_pauseList.get(pauseName))
            play(pauseName);
        else pause(pauseName);
    }

    void play(string name, bool sendEvent = true)
    {
        m_pauseList.set(name, false);

        if (!m_pauseList.get())
        {
            if(sendEvent)
                send(new TimelinePauseEvent(false));
            
            m_director.Play();
        }
    }

    void pause(string name, bool sendEvent = true)
    {
        bool oldPause = m_pauseList.get();

        m_pauseList.set(name, true);

        if (m_pauseList.get() != oldPause)
        {
            if(sendEvent)
                send(new TimelinePauseEvent(true));

            m_director.Pause();
        }
    }

    void run()
    {
        if (m_pauseList.get() || !m_enabled)
            return;

        float time = Time.deltaTime * Options.instance.timelineSpeedValue;
        
        if(m_onFastForward)
        {
            if (m_onFastForwardForward)
                time *= fastForwardSpeed;
            else time *= rewindSpeed;
        }

        m_currentTime += time;
        if (m_currentTime > m_director.duration)
        {
            pause(pauseName);
            m_currentTime = (float)m_director.duration;
        }

        if (m_currentTime < 0)
            m_currentTime = 0;

        m_director.time = m_currentTime;
        m_director.Evaluate();

        Event<TimelineUpdateEvent>.Broadcast(new TimelineUpdateEvent(m_currentTime, (float)m_director.duration, time));
    }

    void stop()
    {
        pause(pauseName);
        updateFastForward();

        m_currentTime = 0;
        m_director.Stop();
        m_director.time = m_currentTime;
        m_director.Evaluate();
        if(m_onFastForward)
        {
            m_onFastForward = false;
            Event<TimelineFastForwardEvent>.Broadcast(new TimelineFastForwardEvent(false, m_onFastForwardForward));
        }
        Event<TimelineStopEvent>.Broadcast(new TimelineStopEvent());
    }

    void send<T>(T value) where T : EventArgs
    {
        if (!m_enabled)
            return;
        Event<T>.Broadcast(value);
    }

    void onPause(PauseEvent e)
    {
        if (e.paused)
            pause(pauseEventName);
        else play(pauseEventName);
    }

    void onPauseTimeline(PauseTimelineEvent e)
    {
        if (e.paused)
            pause(pauseTimelineEventName);
        else play(pauseTimelineEventName);
    }

    void onLockControls(LockPlayerControlesEvent e)
    {
        if (e.locked)
            pause(lockControlsEventName, false);
        else play(lockControlsEventName, false);
    }

    void onRestartTimeline(RestartTimelineEvent e)
    {
        stop();
        play(pauseName);
    }

    public void makeEnableButNotStart()
    {
        m_enabled = true;
    }
}
