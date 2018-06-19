using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

/// <summary>
/// Class statique qui a pour objectif de réaliser la connexion entre l'utilisateur et SaveSystem, quand l'utilisation devient complexe
/// </summary>

static class SaveAttributes
{
    [Serializable]
    class TimelineSaveRewind
    {
        public List<TimelineManager2Logic.RewindPoint> rewindPoints;
    }

    [Serializable]
    class NotebookData
    {
        public List<Notebook.Section> sections;
    }

    public static TimelineCondition.TimelineProperty getTimelineProperty(string name)
    {
        var value = SaveSystem.instance().getInt("Timeline_" + name);

        var property = new TimelineCondition.TimelineProperty();
        property.unlocked = (value & 1) != 0;
        property.enabled = (value & 2) != 0;

        return property;
    }

    public static void setTimelineProperty(string name, int value)
    {
        SaveSystem.instance().set("Timeline_" + name, value);
    }

    public static void setTimelineProperty(string name, bool enabled)
    {
        bool unlocked = enabled || getTimelineProperty(name).unlocked;

        setTimelineProperty(name, (unlocked ? 1 : 0) + (enabled ? 2 : 0));
    }

    public static void removeTimelineProperty(string name)
    {
        SaveSystem.instance().removeInt("Timeline_" + name);
    }

    public static void setCurrentScene(string name)
    {
        SaveSystem.instance().set("Scene", name);
    }

    public static string getCurrentScene()
    {
        return SaveSystem.instance().getString("Scene");
    }

    public struct TimelinePosition
    {
        public int timelineIndex;
        public int pointIndex;
    }

    [Obsolete("This system is not used anymore, need to cleanup.")]
    public static TimelinePosition GetTimelinePosition()
    {
        TimelinePosition p = new TimelinePosition();
        p.timelineIndex = SaveSystem.instance().getInt("TimelineIndex");
        p.pointIndex = SaveSystem.instance().getInt("TimelinePointIndex");

        return p;
    }

    [Obsolete("This system is not used anymore, need to cleanup.")]
    public static void setTimelinePosition(TimelinePosition p)
    {
        SaveSystem.instance().set("TimelineIndex", p.timelineIndex);
        SaveSystem.instance().set("TimelinePointIndex", p.pointIndex);
    }

    public static void setTimelineRewind(List<TimelineManager2Logic.RewindPoint> rewind)
    {
        TimelineSaveRewind r = new TimelineSaveRewind();
        r.rewindPoints = rewind;
        SaveSystem.instance().set("TimelineRewind", JsonUtility.ToJson(r));
    }

    public static List<TimelineManager2Logic.RewindPoint> getTimelineRewind()
    {
        var r = JsonUtility.FromJson<TimelineSaveRewind>(SaveSystem.instance().getString("TimelineRewind"));
        if (r != null && r.rewindPoints != null)
            return r.rewindPoints;
        return new List<TimelineManager2Logic.RewindPoint>();
    }

    public static void setNotebookData(List<Notebook.Section> data)
    {
        NotebookData d = new NotebookData();
        d.sections = data;
        SaveSystem.instance().set("NotebookData", JsonUtility.ToJson(d));
    }

    public static List<Notebook.Section> getNotebookData()
    {
        var d = JsonUtility.FromJson<NotebookData>(SaveSystem.instance().getString("NotebookData"));
        if (d != null && d.sections != null)
            return d.sections;
        return new List<Notebook.Section>();
    }

    public static void setCharactersData(List<Notebook.Section> data)
    {
        NotebookData d = new NotebookData();
        d.sections = data;
        SaveSystem.instance().set("CharactersData", JsonUtility.ToJson(d));
    }

    public static List<Notebook.Section> getCharactersData()
    {
        var d = JsonUtility.FromJson<NotebookData>(SaveSystem.instance().getString("CharactersData"));
        if (d != null && d.sections != null)
            return d.sections;
        return new List<Notebook.Section>();
    }

    public static void setTutoFinished(bool value)
    {
        SaveSystem.instance().set("Tuto", value);
    }

    public static bool getTutoFinished()
    {
        return SaveSystem.instance().getBool("Tuto", false);
    }
}
