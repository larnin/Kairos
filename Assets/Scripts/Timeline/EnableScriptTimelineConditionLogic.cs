using UnityEngine;
using System.Collections;

public class EnableScriptTimelineConditionLogic : MonoBehaviour
{
    [SerializeField] TimelineCondition m_timelineCondition;
    [SerializeField] MonoBehaviour m_script;

    SubscriberList m_subscriberList = new SubscriberList();

    private void Awake()
    {
        m_subscriberList.Add(new Event<TimelinePropertiesChangedEvent>.Subscriber(onTimelinePropertyChange));
        m_subscriberList.Subscribe();
    }

    private void Start()
    {
        exec();
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    void onTimelinePropertyChange(TimelinePropertiesChangedEvent e)
    {
        exec();
    }

    void exec()
    {
        if (m_script == null)
        {
            Debug.LogError("Script not set !");
            return;
        }

        m_script.enabled = m_timelineCondition.check();
    }
}
