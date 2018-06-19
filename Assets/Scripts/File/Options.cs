using UnityEngine;
using System.Collections;
using System;
using System.IO;

public class Options
{
    const string filename = "options.json";

    static Options m_instance = new Options();
    public static Options instance {  get { return m_instance; } }

    [Serializable]
    class OptionsValue
    {
        public float musicValue = 1;
        public float audioValue = 1;
        public int timelineSpeed = 2;
    }

    OptionsValue m_value = new OptionsValue();
    
    public float musicValue
    {
        get { return m_value.musicValue; }
        set
        {
            m_value.musicValue = value;
            save();
        }
    }

    public float audioValue
    {
        get { return m_value.audioValue; }
        set
        {
            m_value.audioValue = value;
            save();
        }
    }
    
    public int timelineSpeed
    {
        get { return m_value.timelineSpeed; }
        set
        {
            m_value.timelineSpeed = value;
            save();
        }
    }
    const int maxIndex = 4;
    const float minSpeedValue = 0.6f;
    const float maxSpeedValue = 1.4f;

    public float timelineSpeedValue { get { return minSpeedValue + (maxSpeedValue - minSpeedValue) / maxIndex * m_value.timelineSpeed; } }

    public Options()
    {
        load();
    }

    void save()
    {
        string filePath = Application.persistentDataPath + "/" + filename;
        try
        {
            var s = JsonUtility.ToJson(m_value);
            File.WriteAllText(filePath, s);
        }
        catch (Exception e)
        {
            Debug.LogWarning("Can't save the options file !");
            Debug.Log(e.ToString());
        }
    }

    void load()
    {
        string filePath = Application.persistentDataPath + "/" + filename;
        try
        {
            if (!File.Exists(filePath))
                save();
            else
            {
                var s = File.ReadAllText(filePath);
                m_value = JsonUtility.FromJson<OptionsValue>(s);
                if (m_value == null)
                {
                    Debug.LogWarning("Can't load the options file !");
                    m_value = new OptionsValue();
                }
            }
        }
        catch (Exception e)
        {
            Debug.LogWarning("Can't load the file !");
            Debug.Log(e.ToString());
        }
    }
}
