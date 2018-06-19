using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.Playables;
using Cinemachine;

public class BackforwardTimelineLogic : MonoBehaviour
{
    [SerializeField] PlayableDirector m_timeline;
    [SerializeField] CinemachineVirtualCamera m_camera;
    [SerializeField] float m_timeLinePlayDelay = 1f;

    private void Start()
    {
        
    }

    public void startTimeline()
    {
        m_timeline.GetComponent<TimelineTrigger2Logic>().makeEnableButNotStart();
        Invoke("DoTimeline", m_timeLinePlayDelay);
        m_camera.Priority = 100;
    }

    private void Update()
    {
        if (m_timeline.time > m_timeline.duration || Mathf.Approximately((float)m_timeline.time, (float)m_timeline.duration))
        {
            onEnd();
        }
    }

    void onEnd()
    {
        Event<EndBackforwardSceneEvent>.Broadcast(new EndBackforwardSceneEvent());
        m_camera.Priority = 0;
    } 

    void DoTimeline()
    {
         Event<RestartTimelineEvent>.Broadcast(new RestartTimelineEvent());
    }
}
