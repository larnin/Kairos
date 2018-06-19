using UnityEngine;
using System.Collections;
using System;
using Sirenix.OdinInspector;
using System.Collections.Generic;

public class SceneStoryLogic : MonoBehaviour
{
    [SerializeField] List<SectionElement> m_story;
    [SerializeField] List<SectionElement> m_characters;

    SubscriberList m_subscriberList = new SubscriberList();

    [Serializable]
    public class SectionElement
    {
        const float maxAlpha = 0.4f;

        [FoldoutGroup("$name")]
        public TimelineCondition2 condition;

        [FoldoutGroup("$name")]
        public string name = "";

        [FoldoutGroup("$name")]
        [Multiline]
        public string text = "";

        [OnInspectorGUI, PropertyOrder(10)]
        private void ColorTheHeader()
        {
            var groupColor = stringToColor(name);

            Color c = new Color(groupColor.r, groupColor.g, groupColor.b, Mathf.Min(groupColor.a, maxAlpha));

            Rect rect = GUILayoutUtility.GetLastRect();
            GUI.color = c;
            GUI.DrawTexture(new Rect(rect.x, rect.y, rect.width, 20), Texture2D.whiteTexture);
            GUI.color = Color.white;
        }

        Color stringToColor(string s)
        {
            if (s.Length == 0)
                return new Color(1, 1, 1, 0);

            int value;
            using (var sha = new System.Security.Cryptography.SHA256Managed())
            {
                byte[] textData = System.Text.Encoding.UTF8.GetBytes(s);
                byte[] hash = sha.ComputeHash(textData);
                value = (int)(BitConverter.ToUInt64(hash, 0) % (1 << 24));
            }
            
            return new Color(value % 256 / 255f, (value >> 8) % 256 / 255f, (value >> 16) % 256 / 255f);
        }
    }

    private void Awake()
    {
        m_subscriberList.Add(new Event<TimelinePropertiesChangedEvent>.Subscriber(onPropertyChange));
        m_subscriberList.Add(new Event<EndSceneEvent>.Subscriber(onEndScene));
        m_subscriberList.Subscribe();
    }

    private void Start()
    {
        updateSections();
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    void updateSections()
    {
        for(int i = 0; i < m_story.Count; i++)
        {
            SectionElement s = m_story[i];
            if (s.condition.check())
                Notebook.instance.enableSection(s.name, s.text);
        }

        for (int i = 0; i < m_characters.Count; i++)
        {
            SectionElement s = m_characters[i];
            if (s.condition.check())
                Notebook.instance.enableCharacter(s.name, s.text);
        }
    }

    void onPropertyChange(TimelinePropertiesChangedEvent e)
    {
        updateSections();
    }

    void onEndScene(EndSceneEvent e)
    {

    }
}
