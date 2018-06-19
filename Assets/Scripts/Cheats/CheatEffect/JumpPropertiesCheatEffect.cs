using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class JumpPropertiesCheatEffect : BaseCheatEffect
{
    [Serializable]
    class ButtonInfos
    {
        public string name;
        [ValueDropdown("getProperties")]
        public List<string> properties = new List<string>();

        List<string> getProperties()
        {
            var t = TimelineManager2Logic.instance();
            if (t == null)
            {
                t = UnityEngine.Object.FindObjectOfType<TimelineManager2Logic>();
                if (t == null)
                    return new List<string>();
            }
            return t.properties;
        }
    }

    [SerializeField] List<ButtonInfos> m_properties = new List<ButtonInfos>();

    bool m_cheatExecuted = false;

    public override void onGui()
    {
        GUI.Label(new Rect(20, 20, 200, 20), "Jump to a scene point");

        Rect r = new Rect(20, 50, 200, 20);

        foreach(var p in m_properties)
        {
            if (GUI.Button(r, p.name))
                execAction(p);

            r.y += 30;
        }
    }

    void execAction(ButtonInfos button)
    {
        m_cheatExecuted = true;

        List<string> validProperties = new List<string>();
        foreach (var p in button.properties)
            if (!SaveAttributes.getTimelineProperty(p).enabled)
                validProperties.Add(p);

        if (validProperties.Count > 0)
            Event<ChangeTimelinePropertiesEvent>.Broadcast(new ChangeTimelinePropertiesEvent(validProperties, 0));
    }

    public override bool onUpdate()
    {
        if (m_properties.Count == 0)
            return false;

        if (Input.GetKeyDown("escape"))
            return false;

        if(m_cheatExecuted)
        {
            m_cheatExecuted = false;
            return false;
        }

        return true;
    }
}