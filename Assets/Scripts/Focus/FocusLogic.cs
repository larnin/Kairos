using UnityEngine;
using System.Collections;

public class FocusLogic : MonoBehaviour
{
    [SerializeField] bool m_showOnGui = false;

    const string focusKeyName = "Focus";

    SubscriberList m_subscriberList = new SubscriberList();

    bool m_pausedEvent = false;
    bool m_lockControlsEvent = false;
    bool m_onFocusMode = false;

    FocusEffectLogic m_focusEffect;

    private void Awake()
    {
        m_subscriberList.Add(new Event<PauseEvent>.Subscriber(onPause));
        m_subscriberList.Add(new Event<LockPlayerControlesEvent>.Subscriber(onLockControls));
        m_subscriberList.Add(new Event<TimelineRewindEventBefore>.Subscriber(onRewindBefore));
        m_subscriberList.Add(new Event<TimelineRewindEvent>.Subscriber(onRewind));
        m_subscriberList.Subscribe();

        m_focusEffect = GetComponent<FocusEffectLogic>();
    }
    
    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    private void Update()
    {
        if (m_pausedEvent || m_lockControlsEvent)
            return;

        if (Input.GetButtonDown(focusKeyName))
            onFocusAction();
    }

    void onFocusAction()
    {
        m_onFocusMode = !m_onFocusMode;
        Event<FocusEvent>.Broadcast(new FocusEvent(m_focusEffect));
        Event<PauseTimelineEvent>.Broadcast(new PauseTimelineEvent(m_onFocusMode));

        if (m_onFocusMode)
            m_focusEffect.startFocus();
        else m_focusEffect.endFocus();
    }

    private void OnGUI()
    {
        if (m_onFocusMode && m_showOnGui)
            GUI.Label(new Rect(2, 2, 100, 30), "Focus !");
    }

    void onPause(PauseEvent e)
    {
        m_pausedEvent = e.paused;
        if (m_onFocusMode)
            onFocusAction();
    }

    void onLockControls(LockPlayerControlesEvent e)
    {
        m_lockControlsEvent = e.locked;
        if (m_onFocusMode)
            onFocusAction();
    }

    void onRewindBefore(TimelineRewindEventBefore e)
    {
        if(m_onFocusMode)
        {
            m_focusEffect.endFocus();
        }
    }

    void onRewind(TimelineRewindEvent e)
    {
        if (m_onFocusMode)
        {
            m_focusEffect.startFocus();
        }
    }


}
