using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using Sirenix.OdinInspector;
using System.Collections;
using DG.Tweening;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class TimelineManager2Logic : MonoBehaviour
{
    [Serializable]
    public class TimelineElement
    {
        const float maxAlpha = 0.4f;

        [FoldoutGroup("$name"), HorizontalGroup("$name/"), LabelWidth(50)]
        public string name = "";
        [FoldoutGroup("$name"), HorizontalGroup("$name/", Width = 10), HideLabel, LabelWidth(1)]
        public Color groupColor = new Color(1, 1, 1, 0);
        [FoldoutGroup("$name")]
        public TimelineCondition2 m_condition;
        [FoldoutGroup("$name")]
        public List<GameObject> objects;

        [OnInspectorGUI, PropertyOrder(10)]
        private void ColorTheHeader()
        {
            Color c = new Color(groupColor.r, groupColor.g, groupColor.b, Mathf.Min(groupColor.a, maxAlpha));

            Rect rect = GUILayoutUtility.GetLastRect();
            GUI.color = c;
            GUI.DrawTexture(new Rect(rect.x, rect.y, rect.width, 20), Texture2D.whiteTexture);
            GUI.color = Color.white;
        }
    }

    [Serializable]
    public class TimelineProperty
    {
        [HideLabel]
        [CustomValueDrawer("drawProperty")]
        [HorizontalGroup]
        public string property;

        string drawProperty(string value, GUIContent label)
        {
            Color unsetColor = new Color(1, .6f, .6f);
            Color unlockedColor = new Color(1, 1, .5f);
            Color setColor = new Color(.5f, 1, .5f);

            var tmp = GUI.color;

            var propertyValue = SaveAttributes.getTimelineProperty(value);
            if (propertyValue.enabled)
                GUI.color = setColor;
            else if (propertyValue.unlocked)
                GUI.color = unlockedColor;
            else GUI.color = unsetColor;
            value = GUILayout.TextField(value);
            GUI.color = tmp;
            return value;
        }

        [Button("S")]
        [GUIColor(0, 1, 0)]
        [HorizontalGroup(width: 20)]
        void set()
        {
            SaveAttributes.setTimelineProperty(property, true);
            updateScene();
        }

        [Button("R")]
        [GUIColor(1, 1, 0)]
        [HorizontalGroup(width: 20)]
        void reset()
        {
            SaveAttributes.setTimelineProperty(property, 1);
            updateScene();
        }

        [Button("D")]
        [GUIColor(1, 0, 0)]
        [HorizontalGroup(width: 20)]
        void delete()
        {
            SaveAttributes.setTimelineProperty(property, 0);
            updateScene();
        }

        void updateScene()
        {
#if UNITY_EDITOR
            if (EditorApplication.isPlaying)
            {
                Event<ChangeTimelinePropertiesEvent>.Broadcast(new ChangeTimelinePropertiesEvent(new List<string>(), 0, false));
            }
#endif 
        }
    }


    [Serializable]
    public class RewindPoint
    {
        public RewindPoint(float _balanceOfCoherence, List<string> _properties)
        {
            balanceOfCoherenceValue = _balanceOfCoherence;
            properties = _properties;
        }
        public float balanceOfCoherenceValue;
        public List<string> properties;
    }
    
    [SerializeField] float m_effectTime = 2f;
    
    [SerializeField] List<TimelineProperty> m_properties;
    public List<string> properties { get
        {
            List<string> properties = new List<string>();
            foreach (var p in m_properties)
                properties.Add(p.property);
            return properties;
        }
    }
    
    [SerializeField] List<TimelineElement> m_elements = new List<TimelineElement>();
    List<int> m_enabledElements = new List<int>();

    SubscriberList m_subscriberList = new SubscriberList();
    List<RewindPoint> m_rewindPoints = new List<RewindPoint>();

    static TimelineManager2Logic m_instance;

    static void setInstance(TimelineManager2Logic obj)
    {
        if(!(m_instance == null || obj == m_instance))
            Debug.LogError("Do you have two TimelineManager2Logic in the scene ?");

        m_instance = obj;
    }

    public static TimelineManager2Logic instance()
    {
        return m_instance;
    }

    [OnInspectorGUI]
    void onInspector()
    {
        setInstance(this);
    }

    private void Awake()
    {
        setInstance(this);

        m_subscriberList.Add(new Event<ChangeTimelinePropertiesEvent>.Subscriber(onPropertyChange));
        m_subscriberList.Add(new Event<TimelineRewindEvent>.Subscriber(onRewind));
        m_subscriberList.Add(new Event<TimelineClearEvent>.Subscriber(onClear));
        m_subscriberList.Add(new Event<CleanRewindEvent>.Subscriber(onClearRewind));
        m_subscriberList.Add(new Event<TimelineRewindEventBefore>.Subscriber(timelineRewindBefore));
        m_subscriberList.Subscribe();

        m_rewindPoints = SaveAttributes.getTimelineRewind();
    }

    private void Start()
    {
		Event<UpdateCurrentTimelineIndexEvent>.Broadcast(new UpdateCurrentTimelineIndexEvent(m_rewindPoints.Count));
		for (int i = 0; i < m_elements.Count; i++)
		{
            bool enabled = m_elements[i].objects.Count > 0 && m_elements[i].objects[0].activeInHierarchy;

            if (enabled)
                m_enabledElements.Add(i);

            foreach (var o in m_elements[i].objects)
                o.SetActive(enabled);
		}

		check(true);
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    void check(bool instant = false)
    {
        List<bool> stateList = new List<bool>();

        foreach (var e in m_elements)
            stateList.Add(e.m_condition.check());

        List<int> enableList = new List<int>();
        List<int> disableList = new List<int>();

        for (int i = 0; i < m_elements.Count; i++)
        {
            bool currentEnabled = m_enabledElements.Contains(i);
            if (currentEnabled != stateList[i])
            {
                if (currentEnabled)
                    disableList.Add(i);
                else enableList.Add(i);
            }
        }
		
		disableElements(disableList, instant);
		enableElements(enableList, instant);

        if (disableList.Count > 0 || enableList.Count > 0)
        {
            Event<RebuildNavmeshEvent>.Broadcast(new RebuildNavmeshEvent());
            Event<RestartTimelineEvent>.Broadcast(new RestartTimelineEvent());
        }
    }

    void enableElements(List<int> list, bool instant)
    {
        foreach (var i in list)
        {
            foreach (var o in m_elements[i].objects)
            {
                if (o)
                {
                    o.SetActive(true);
					if(!instant)
						animateObject(o, true);
                }
            }

            m_enabledElements.Add(i);
        }
    }

    void disableElements(List<int> list, bool instant)
    {
        foreach (var i in list)
        {
            foreach (var o in m_elements[i].objects)
            {
				if (!instant)
					animateObject(o, false);
				else o.SetActive(false);
            }

            m_enabledElements.Remove(i);
        }
    }

    void animateObject(GameObject obj, bool isAppearing)
    {
        Renderer[] renderers = obj.GetComponentsInChildren<Renderer>();

        List<Renderer> ValidRenderers = new List<Renderer>();
        foreach (Renderer e in renderers)
        {
            if (e.material.HasProperty("_Apparition"))
                ValidRenderers.Add(e);
        }
        if(ValidRenderers.Count != 0)
            StartCoroutine(animationAppearing(isAppearing, ValidRenderers, obj));
        else obj.SetActive(isAppearing);
    }

    IEnumerator animationAppearing(bool isAppearing, List<Renderer> renderers, GameObject gameObject = null)
    {
        float startValue = isAppearing ? 0f : 1f;
        float endValue = isAppearing ? 1f : 0f;
        float time = 0f;
        while (time < m_effectTime)
        {
            float value = time / m_effectTime;
            value = Mathf.Lerp(startValue, endValue, value);
            foreach(var renderer in renderers)
                renderer.material.SetFloat("_Apparition", value);

            yield return null;
            time += Time.deltaTime;
        }

        if (!isAppearing)
            gameObject.SetActive(false);
    }

    void onPropertyChange(ChangeTimelinePropertiesEvent e)
    {
        if(e.reset)
        {
            SaveSystem.instance().reset();
            m_rewindPoints.Clear();
            Event<UpdateCurrentTimelineIndexEvent>.Broadcast(new UpdateCurrentTimelineIndexEvent(m_rewindPoints.Count));
        }

        if (e.createRewindPoint)
        {
            m_rewindPoints.Add(new RewindPoint(e.balanceOfCoherence, e.properties));
            Event<UpdateCurrentTimelineIndexEvent>.Broadcast(new UpdateCurrentTimelineIndexEvent(m_rewindPoints.Count));
            SaveAttributes.setTimelineRewind(m_rewindPoints);
        }

        foreach (var p in e.properties)
            SaveAttributes.setTimelineProperty(p, true);

        Event<AddBalanceOfCoherenceValueEvent>.Broadcast(new AddBalanceOfCoherenceValueEvent(e.balanceOfCoherence > 0, Mathf.Abs(e.balanceOfCoherence)));

        check();
        Event<TimelinePropertiesChangedEvent>.Broadcast(new TimelinePropertiesChangedEvent(false));
    }

    void onRewind(TimelineRewindEvent e)
    {
        if (m_rewindPoints.Count == 0)
        {
            Event<UpdateCurrentTimelineIndexEvent>.Broadcast(new UpdateCurrentTimelineIndexEvent(m_rewindPoints.Count));
            return;
        }

        var value = m_rewindPoints[m_rewindPoints.Count - 1];

        Event<AddBalanceOfCoherenceValueEvent>.Broadcast(new AddBalanceOfCoherenceValueEvent(value.balanceOfCoherenceValue < 0, Mathf.Abs(value.balanceOfCoherenceValue)));

        foreach (var p in value.properties)
            SaveAttributes.setTimelineProperty(p, false);

        m_rewindPoints.RemoveAt(m_rewindPoints.Count - 1);
        SaveAttributes.setTimelineRewind(m_rewindPoints);
        Event<UpdateCurrentTimelineIndexEvent>.Broadcast(new UpdateCurrentTimelineIndexEvent(m_rewindPoints.Count));

        check();
        Event<TimelinePropertiesChangedEvent>.Broadcast(new TimelinePropertiesChangedEvent(true));
    }

    void onClearRewind(CleanRewindEvent e)
    {
        m_rewindPoints.Clear();
        Event<UpdateCurrentTimelineIndexEvent>.Broadcast(new UpdateCurrentTimelineIndexEvent(m_rewindPoints.Count));
        SaveAttributes.setTimelineRewind(m_rewindPoints);
    }

    void onClear(TimelineClearEvent e)
    {
        foreach(var p in m_properties)
            SaveAttributes.removeTimelineProperty(p.property);

        m_rewindPoints.Clear();
        Event<UpdateCurrentTimelineIndexEvent>.Broadcast(new UpdateCurrentTimelineIndexEvent(m_rewindPoints.Count));
        SaveAttributes.setTimelineRewind(m_rewindPoints);
    }

    void timelineRewindBefore(TimelineRewindEventBefore e)
    {
        StopAllCoroutines();
        check(true);
    }
}