using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class MainMenuActButtonLogic : MonoBehaviour
{
    [Serializable]
    class Section
    {
        public string name;
        [Multiline]
        public string text;
    }

    [SerializeField] string levelName;
    [SerializeField] List<Section> m_story;
    [SerializeField] List<Section> m_characters;

    public void exec()
    {
        SaveSystem.instance().reset();
        Notebook.instance.clear();
        foreach (var e in m_story)
            Notebook.instance.enableSection(e.name, e.text);
        foreach (var e in m_characters)
            Notebook.instance.enableCharacter(e.name, e.text);
        SceneSystem.changeScene(levelName);

    }
}