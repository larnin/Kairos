using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Collections.Generic;

public class TimelineRenderEffectLogic : MonoBehaviour
{
    [SerializeField] GameObject m_pointPrefab;
    [SerializeField] List<int> m_timelinePoints;
    Image m_backLine;
    Image m_frontLine;

    int m_currentTimeline = 0;
    int m_currentPoint = 0;
    List<TimelineObjectEffect> m_points = new List<TimelineObjectEffect>();
    float m_width;
    float m_valueStart;
    float m_valueEnd;

    SubscriberList m_subscriberList = new SubscriberList();

    float lastTimeSet = 0;

    private void Awake()
    {
        m_subscriberList.Add(new Event<UpdateCurrentTimelineIndexEvent>.Subscriber(onUpdateIndex));
        m_subscriberList.Add(new Event<TimelineUpdateEvent>.Subscriber(onTimelineUpdated));
        m_subscriberList.Add(new Event<TimelineStopEvent>.Subscriber(onTimelineStop));
        m_subscriberList.Subscribe();
        m_backLine = transform.Find("ImageBack").GetComponent<Image>();
        m_frontLine = transform.Find("ImageFront").GetComponent<Image>();
        m_width = m_backLine.rectTransform.rect.width * m_backLine.transform.localScale.x;
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    void initListPoints()
    {
        foreach (var p in m_points)
            Destroy(p.gameObject);
        m_points.Clear();

        if(m_timelinePoints[m_currentTimeline] == 1)
        {
            createObject(Vector3.zero);
        }
        else
        {
            float objectDelta = m_width / (m_timelinePoints[m_currentTimeline] - 1);
            for (int i = 0; i <= m_currentPoint; i++)
                createObject(new Vector3(objectDelta * i - m_width / 2, 0, 0));
        }

        m_points[m_currentPoint].setCurrent(true);
        
        if (m_currentPoint == 0)
        {
            m_valueStart = 0;
            m_valueEnd = 0;
        }
        else
        {
            m_valueStart = (float)(m_currentPoint - 1) / (m_timelinePoints[m_currentTimeline] - 1);
            m_valueEnd = (float)m_currentPoint / (m_timelinePoints[m_currentTimeline] - 1);
        }

        m_frontLine.fillAmount = m_valueStart;
    }

    void createObject(Vector3 pos)
    {
        var obj = Instantiate(m_pointPrefab, transform);
        obj.transform.localPosition = pos;
        m_points.Add(obj.GetComponent<TimelineObjectEffect>());
    }

    void onUpdateIndex(UpdateCurrentTimelineIndexEvent e)
    {
        m_currentPoint = e.index;
        m_currentTimeline = 0;

        foreach(var p in m_timelinePoints)
        {
            if (m_currentPoint >= p)
            {
                m_currentPoint -= p;
                m_currentTimeline++;
            }
            else break;
        }

        if(m_currentTimeline >= m_timelinePoints.Count)
        {
            m_currentTimeline = m_timelinePoints.Count - 1;
            m_currentPoint = m_timelinePoints[m_currentTimeline] - 1;
        }

        gameObject.SetActive(true);

        initListPoints();
    }

    void onTimelineUpdated(TimelineUpdateEvent e)
    {
        if (m_frontLine != null)
            m_frontLine.fillAmount = (e.currentTime / e.totalTime) * (m_valueEnd - m_valueStart) + m_valueStart;
    }

    void onTimelineStop(TimelineStopEvent e)
    {
        if(m_frontLine != null)
            m_frontLine.fillAmount = m_valueStart;
    }
}
