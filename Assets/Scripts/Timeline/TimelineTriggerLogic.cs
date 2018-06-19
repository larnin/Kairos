using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.Playables;

public class TimelineTriggerLogic : TriggerBaseLogic
{
    const string playButtonName = "TimelinePlayPause";
    const string stopButtonName = "TimelineStop";
    const float fastForwardDelay = 0.5f;
    const float fastForwardSpeed = 10.0f;
    const float rewindSpeed = 5.0f;
    const string pauseName = "pause";
    const string pauseEventName = "pauseEvent";
    const string pauseTimelineEventName = "pauseTimeline";
    const string lockControlsEventName = "lockControls";
    const float readingSpeed = 0.8f;

	class PauseList
    {
        Dictionary<string, bool> m_pauses = new Dictionary<string, bool>();

        public void set(string key, bool value)
        {
            bool oldPause = get();
            m_pauses[key] = value;

            if (get() != oldPause)
                Event<TimelinePauseEvent>.Broadcast(new TimelinePauseEvent(!oldPause));
        }

        public bool get(string key)
        {
            if (!m_pauses.ContainsKey(key))
                return false;
            return m_pauses[key];
        }

        public bool get()
        {
            foreach(var it in m_pauses)
            {
                if (it.Value)
                    return true;
            }
            return false;
        }
    }

    PlayableDirector m_director;
    bool m_onZone = false;

    float m_playPressDuration = 0;
    float m_rewindPressDuration = 0;
    bool m_playPressed = false;
    float m_currentTime = 0;
    bool m_lastFrameFastForward = false;

    PauseList m_pauseList = new PauseList();

    SubscriberList m_subscriberList = new SubscriberList();

    private void Awake()
    {
        m_director = GetComponent<PlayableDirector>();
        m_director.Stop();
        m_director.timeUpdateMode = DirectorUpdateMode.Manual;

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

    public override void onEnter(TriggerInteractionLogic entity)
    {
        m_onZone = true;
        m_pauseList.set(pauseName, false);
        m_currentTime = 0;
        m_director.Play();
        m_director.time = m_currentTime;
        m_director.Evaluate();
    }

    public override void onExit(TriggerInteractionLogic entity)
    {
        m_onZone = false;
        m_playPressed = false;
        m_pauseList.set(pauseName, true);
        m_playPressDuration = 0;
        m_currentTime = 0;
        m_director.Stop();
    }

    private void Update()
    {
        if (!m_onZone)
            return;

        if(Input.GetButton(playButtonName))
        {
            m_playPressed = true;
            m_playPressDuration += Time.deltaTime;
        }
        else if(m_playPressed)
        {
            m_playPressed = false;
            if (m_playPressDuration < fastForwardDelay) 
                playPauseTrack();
            m_playPressDuration = 0;
        }

        if (Input.GetButton(stopButtonName))
        {
            if (m_rewindPressDuration == 0)
            {
                m_pauseList.set(pauseName, false);
                Event<TimelineFastForwardEvent>.Broadcast(new TimelineFastForwardEvent(true, false));
            }
            m_rewindPressDuration += Time.deltaTime;
        }
        else
        {
            if (m_rewindPressDuration != 0)
                Event<TimelineFastForwardEvent>.Broadcast(new TimelineFastForwardEvent(false, false));
            m_rewindPressDuration = 0;
        }
        
        if(m_rewindPressDuration > 0)
        {
            rewindTrack();
        }
        else if (m_playPressDuration > fastForwardDelay && m_playPressed)
        {
            fastForwardTrack();
            if (!m_lastFrameFastForward)
            {
                if (m_pauseList.get(pauseName))
                    playPauseTrack();
                Event<TimelineFastForwardEvent>.Broadcast(new TimelineFastForwardEvent(true, true));
            }
            m_lastFrameFastForward = true;
        }
        else
        {
            updateTrack();
            if (m_lastFrameFastForward)
                Event<TimelineFastForwardEvent>.Broadcast(new TimelineFastForwardEvent(false, true));
            m_lastFrameFastForward = false;
        }
	}

    void playPauseTrack()
    {
        m_pauseList.set(pauseName, !m_pauseList.get(pauseName));
        if(m_currentTime >= m_director.duration)
        {
            m_currentTime = 0;
            m_director.time = 0;
            m_director.Evaluate();
        }
        if (m_pauseList.get(pauseName))
            m_director.Pause();
        else m_director.Play();
    }

    void stopTrack()
    {
        m_pauseList.set(pauseName, true);
        m_currentTime = 0;
        m_director.Stop();
        m_director.time = m_currentTime;
        m_director.Evaluate();
        Event<TimelineStopEvent>.Broadcast(new TimelineStopEvent());
        Event<TimelineFastForwardEvent>.Broadcast(new TimelineFastForwardEvent(false, true));
    }

    void rewindTrack()
    {
        updateTimeTrack(- Time.deltaTime * rewindSpeed);
    }

    void fastForwardTrack()
    {
        updateTimeTrack(Time.deltaTime * fastForwardSpeed);
    }

    void updateTrack()
    {
        updateTimeTrack(Time.deltaTime);
    }

    void updateTimeTrack(float deltaTime)
    {
        if (m_pauseList.get())
            return;

            m_currentTime += deltaTime * readingSpeed;
        if (m_currentTime > m_director.duration)
        {
            m_currentTime = (float)m_director.duration;
            m_pauseList.set(pauseName, true);
            m_director.Pause();
            Event<TimelineFastForwardEvent>.Broadcast(new TimelineFastForwardEvent(false, true));
        }

        if (m_currentTime < 0)
            m_currentTime = 0;

        m_director.time = m_currentTime;
        m_director.Evaluate();

        Event<TimelineUpdateEvent>.Broadcast(new TimelineUpdateEvent(m_currentTime, (float)m_director.duration, deltaTime * readingSpeed));
    }

    void onPause(PauseEvent e)
    {
        m_pauseList.set(pauseEventName, e.paused);
    }

    void onPauseTimeline(PauseTimelineEvent e)
    {
        m_pauseList.set(pauseTimelineEventName, e.paused);
        Event<TimelineFastForwardEvent>.Broadcast(new TimelineFastForwardEvent(false, true));
    }

    void onLockControls(LockPlayerControlesEvent e)
    {
        m_pauseList.set(lockControlsEventName, e.locked);
        Event<TimelineFastForwardEvent>.Broadcast(new TimelineFastForwardEvent(false, true));
    }

    void onRestartTimeline(RestartTimelineEvent e)
    {
        stopTrack();
    }
}