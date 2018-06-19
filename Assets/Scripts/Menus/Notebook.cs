using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class Notebook
{
    static Notebook m_instance = new Notebook();
    public static Notebook instance { get { return m_instance; } }

    [Serializable]
    public class Section
    {
        public Section(string _title, List<string> _elements)
        {
            title = _title;
            elements = _elements;
        }

        public Section(string _title, string firstElement)
        {
            title = _title;
            elements = new List<string>();
            elements.Add(firstElement);
        }

        public string title;
        public List<string> elements;
    }

    List<Section> m_sections = new List<Section>();
    List<Section> m_characters = new List<Section>();

    Notebook()
    {
        load();
    }

    public void enableSection(string sectionName, string element)
    {
        var s = m_sections.Find(x => { return x.title == sectionName; });
        if (s == null)
            m_sections.Add(new Section(sectionName, element));
        else
        {
            var e = s.elements.IndexOf(element);
            if (e < 0)
                s.elements.Add(element);
        }
        save();
    }

    public List<string> getSection(string sectionName)
    {
        var s = m_sections.Find(x => { return x.title == sectionName; });
        if (s == null)
            return null;
        return s.elements;
    }

    public List<string> getSectionList()
    {
        List<string> sections = new List<string>();
        foreach (var s in m_sections)
            sections.Add(s.title);
        return sections;
    }

    public void enableCharacter(string sectionName, string element)
    {
        var s = m_characters.Find(x => { return x.title == sectionName; });
        if (s == null)
            m_characters.Add(new Section(sectionName, element));
        else
        {
            var e = s.elements.IndexOf(element);
            if (e < 0)
                s.elements.Add(element);
        }
        save();
    }

    public List<string> getCharacter(string sectionName)
    {
        var s = m_characters.Find(x => { return x.title == sectionName; });
        if (s == null)
            return null;
        return s.elements;
    }

    public List<string> getCharacterList()
    {
        List<string> sections = new List<string>();
        foreach (var s in m_characters)
            sections.Add(s.title);
        return sections;
    }

    public void clear()
    {
        m_sections.Clear();
        m_characters.Clear();
    }

    void save()
    {
        SaveAttributes.setNotebookData(m_sections);
        SaveAttributes.setCharactersData(m_characters);
    }

    void load()
    {
        m_sections = SaveAttributes.getNotebookData();
        m_characters = SaveAttributes.getCharactersData();
    }
}
