using UnityEngine;
using ExpressionParser;
using System.Collections;
using System.Collections.Generic;
using System;

public class TimelineManagerLogic : MonoBehaviour
{
    [Serializable]
    public class TimelineElement
    {
        public TimelineCondition m_condition;
        public List<GameObject> objects;
    }

    [SerializeField] float m_effectTime = 2f;
    [SerializeField] List<TimelineElement> m_elements = new List<TimelineElement>();

    List<int> m_enabledElements = new List<int>();

    SubscriberList m_subscriberList = new SubscriberList();

    private void Start()
    {
        m_subscriberList.Add(new Event<TimelinePropertiesChangedEvent>.Subscriber(onPropertyChanged));
        m_subscriberList.Subscribe();

        for (int i = 0; i < m_elements.Count; i++)
        {
            if(m_elements[i].objects.Count > 0 && m_elements[i].objects[0].activeInHierarchy)
                m_enabledElements.Add(i);
        }

        check();
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    void check()
    {
        List<bool> stateList = new List<bool>();

        foreach(var e in m_elements)
            stateList.Add(e.m_condition.check());

        List<int> enableList = new List<int>();
        List<int> disableList = new List<int>();

        for(int i = 0; i < m_elements.Count; i++)
        {
            bool currentEnabled = m_enabledElements.Contains(i);
            if(currentEnabled != stateList[i])
            {
                if (currentEnabled)
                    disableList.Add(i);
                else enableList.Add(i);
            }
        }

        disableElements(disableList);
        enableElements(enableList);

        if(disableList.Count > 0 || enableList.Count > 0)
        {
            Event<RebuildNavmeshEvent>.Broadcast(new RebuildNavmeshEvent());
            Event<RestartTimelineEvent>.Broadcast(new RestartTimelineEvent());
        }
    }

    void enableElements(List<int> list)
    {
        foreach(var i in list)
        {
            foreach(var o in m_elements[i].objects)
            {
                if (o)
                {
                    o.SetActive(true);
                    TryAnimation(o, true);
                }
            }
                

            m_enabledElements.Add(i);
        }
    }

    void disableElements(List<int> list)
    {
        foreach(var i in list)
        {
            foreach (var o in m_elements[i].objects)
            {
                TryAnimation(o, false);
            }
                

            m_enabledElements.Remove(i);
        }
    }

    void onPropertyChanged(TimelinePropertiesChangedEvent e)
    {
        check();
    }

    void TryAnimation(GameObject obj, bool isAppearing)
    {
        Renderer[] renderers = obj.GetComponentsInChildren<Renderer>();
        bool findCorrect = false;
        foreach (Renderer e in renderers)
        {
            if(e.material.HasProperty("_Apparition"))
            {
                StartCoroutine(animationAppearing(isAppearing, e, obj));
                findCorrect = true;
            }
        }

        if( (renderers.Length == 0) || (!findCorrect) )
        {
            obj.SetActive(isAppearing);
        }
    }

    IEnumerator animationAppearing(bool isAppearing, Renderer renderer, GameObject gameObject = null)
    {
        float startValue = isAppearing ? 0f : 1f;
        float endValue = isAppearing ? 1f : 0f;
        float time = 0f;
        while (time < m_effectTime)
        {
            float value = time / m_effectTime;
            value = Mathf.Lerp(startValue, endValue, value);
            renderer.material.SetFloat("_Apparition", value);
            yield return null;
            time += Time.deltaTime;
        }

        if (!isAppearing)
        {
            gameObject.SetActive(false);
        } 
    }
}
