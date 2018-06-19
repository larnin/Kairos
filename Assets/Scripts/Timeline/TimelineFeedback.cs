using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.PostProcessing;
using DG.Tweening;

public class TimelineFeedback : MonoBehaviour
{
    const string fastForwardName = "_FastForward";
    const string directionName = "_Sens";
    const string deadEndName = "_GameOver";
    const string pauseName = "_Pause";

    [SerializeField] bool m_debug;
    [SerializeField] float m_duration = 1f;
    //[SerializeField] float m_deadEndDuration = 10f;
    [SerializeField] PostProcessingProfile m_ppp;
    [SerializeField] Material m_pppMat;

    [SerializeField] List<ParticleSystem> m_particleSystems = new List<ParticleSystem>();

    ChromaticAberrationModel.Settings m_chromSet;

    SubscriberList m_subscriberList = new SubscriberList();
    Tween m_deadEndTween = null;

    public struct State
    {
        public bool fastForward
        {
            get
            {
                if (paused || m_deadEnd)
                    return false;
                return m_fastForward;
            }
            set { m_fastForward = value; }
        }
        public bool fastForwardForward
        {
            get { return m_fastForwardForward; }
            set { m_fastForwardForward = value; }
        }
        public bool paused
        {
            get
            {
                if (m_deadEnd)
                    return false;
                return m_paused;
            }
            set { m_paused = value; }
        }
        public bool deadEnd
        {
            get { return m_deadEnd; }
            set { m_deadEnd = value; }
        }

        bool m_fastForward;
        bool m_fastForwardForward;
        bool m_paused;
        bool m_deadEnd;
		public float deadEndDuration;

	} 

    bool m_onExec = false;
    bool m_needToExec = false;
    State m_needToExecState;

    State m_state = new State();

    private void Start()
    {
        m_subscriberList.Add(new Event<TimelineFastForwardEvent>.Subscriber(onFastForward));
        m_subscriberList.Add(new Event<TimelinePauseEvent>.Subscriber(onPause));
        m_subscriberList.Add(new Event<TimelineDeadEndEvent>.Subscriber(onDeadEnd));
        m_subscriberList.Add(new Event<TimelineRewindEvent>.Subscriber(onRewind));
        m_subscriberList.Subscribe();

        m_state.fastForward = false;
        m_state.fastForwardForward = false;
        m_state.paused = false;
        m_state.deadEnd = false;
        m_needToExecState = m_state;

        initializePostProcess();
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    void initializePostProcess()
    {
        m_chromSet = m_ppp.chromaticAberration.settings;
        m_chromSet.intensity = 0;
        m_ppp.chromaticAberration.settings = m_chromSet;
        m_pppMat.SetFloat(fastForwardName, 0);
        m_pppMat.SetFloat(directionName, 0);
        m_pppMat.SetFloat(deadEndName, 0);
        m_pppMat.SetFloat(pauseName, 0);
    }

    private void OnGUI()
    {
        if(m_debug)
            GUI.Label(new Rect(5, 5, 200, 200), "Pause\t\t" + m_state.paused 
                                              + "\nFastforward\t" + m_state.fastForward 
                                              + "\ndirection\t\t" + m_state.fastForwardForward 
                                              + "\nDead end\t\t" + m_state.deadEnd);
    }

    void updateEffect(State s)
    {
        m_needToExecState = s;

        if(m_onExec)
        {
            m_needToExec = true;
            return;
        }

        m_onExec = true;

        doOffPause(s);
    }

    void doOffPause(State s)
    {
        if (!s.paused && m_state.paused)
        {
            foreach (var p in m_particleSystems)
            {
                if(p)
                    p.Play(true);
            }
                
            m_pppMat.DOFloat(0, pauseName, m_duration).OnComplete(() => doOffFastForward(s));
        }
        else doOffFastForward(s);
    }

    void doOffFastForward(State s)
    {
        if (!s.fastForward && m_state.fastForward)
        {
            m_pppMat.SetFloat(directionName, s.fastForwardForward ? 1 : 0);
            m_pppMat.DOFloat(0, fastForwardName, m_duration).OnComplete(() => doOffDeadEnd(s));
        }
        else doOffDeadEnd(s);
    }

    void doOffDeadEnd(State s)
    {
        if (!s.deadEnd && m_state.deadEnd)
            m_pppMat.DOFloat(0, deadEndName, m_duration).OnComplete(() => doOnPause(s));
        else doOnPause(s);
    }

    void doOnPause(State s)
    {
        if (s.paused && !m_state.paused)
        {
            foreach (var p in m_particleSystems)
            {
                if(p)
                    p.Pause(true);
            }
                
            m_pppMat.DOFloat(1, pauseName, m_duration).OnComplete(() => doOnFastForward(s));
        }
        else doOnFastForward(s);
    }

    void doOnFastForward(State s)
    {
        if (s.fastForward && !m_state.fastForward || (s.fastForward && s.fastForwardForward != m_state.fastForwardForward))
        {
            m_pppMat.DOFloat(s.fastForwardForward ? 1 : 0, directionName, m_duration);
            m_pppMat.DOFloat(1, fastForwardName, m_duration).OnComplete(() => doOnDeadEnd(s));
        }
        else doOnDeadEnd(s);
    }

    void doOnDeadEnd(State s)
    {
        if (s.deadEnd && !m_state.deadEnd)
            m_deadEndTween = m_pppMat.DOFloat(1, deadEndName, s.deadEndDuration).OnComplete(() => 
            {
                m_deadEndTween = null;
                doEnd(s);
            });
        else doEnd(s);
    }

    void doEnd(State s)
    {
        m_state = s;
        m_onExec = false;

        if(m_needToExec)
        {
            m_needToExec = false;
            updateEffect(m_needToExecState);
        }
    }

    void onFastForward(TimelineFastForwardEvent e)
    {
        var state = m_needToExecState;
        state.fastForward = e.started;
        state.fastForwardForward = e.forward;
        updateEffect(state);
    }

    void onPause(TimelinePauseEvent e)
    {
        var state = m_needToExecState;
        state.paused = e.paused;
        updateEffect(state);
    }

    void onDeadEnd(TimelineDeadEndEvent e)
    {
		var state = m_needToExecState;
		state.deadEndDuration = e.duration;
        state.deadEnd = true;
        updateEffect(state);
    }

    void onRewind(TimelineRewindEvent e)
    {
        var state = m_needToExecState;
        state.deadEnd = false;
        if (m_deadEndTween != null)
            m_deadEndTween.Complete();
        updateEffect(state);
    }
}