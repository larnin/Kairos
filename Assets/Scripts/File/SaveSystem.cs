using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEngine;

public class SaveSystem
{
    static int version = 1;

    Save m_save = new Save();

    string filename = "Save.json";

    static SaveSystem m_instance = new SaveSystem();
    public static SaveSystem instance()
    {
        return m_instance;
    }

    public SaveSystem()
    {
        Load();
    }

    void Load()
    {
        string filePath = Application.persistentDataPath + "/" + filename;
        try
        {
            if (!File.Exists(filePath))
                save();
            else
            {
                var s = File.ReadAllText(filePath);
                m_save = JsonUtility.FromJson<Save>(s);
                if (m_save == null)
                    Debug.LogWarning("Can't load the file !");
            }
        }
        catch (Exception e)
        {
            Debug.LogWarning("Can't load the file !");
            Debug.Log(e.ToString());
            reset();
        }

        if (m_save.version != version)
            reset();
    }

    void save()
    {
        string filePath = Application.persistentDataPath + "/" + filename;
        try
        {
            var s = JsonUtility.ToJson(m_save);
            File.WriteAllText(filePath, s);
        }
        catch (Exception e)
        {
            Debug.LogWarning("Can't save the file !");
            Debug.Log(e.ToString());
        }
    }

    public void reset()
    {
        m_save = defaultSave();
        save();
    }

    public void set(string key, int value)
    {
        var item = m_save.itemsInt.Find(x => { return x.key == key; });
        if (item != null)
            item.value = value;
        else m_save.itemsInt.Add(new Save.ItemInt(key, value));
        save();
    }

    public void set(string key, float value)
    {
        var item = m_save.itemsFloat.Find(x => { return x.key == key; });
        if (item != null)
            item.value = value;
        else m_save.itemsFloat.Add(new Save.ItemFloat(key, value));
        save();
    }

    public void set(string key, bool value)
    {
        var item = m_save.itemsBool.Find(x => { return x.key == key; });
        if (item != null)
            item.value = value;
        else m_save.itemsBool.Add(new Save.ItemBool(key, value));
        save();
    }

    public void set(string key, string value)
    {
        var item = m_save.itemsString.Find(x => { return x.key == key; });
        if (item != null)
            item.value = value;
        else m_save.itemsString.Add(new Save.ItemString(key, value));
        save();
    }

    public int getInt(string key, int defaultValue = 0)
    {
        var item = m_save.itemsInt.Find(x => { return x.key == key; });
        if (item != null)
            return item.value;
        return defaultValue;
    }

    public float getFloat(string key, float defaultValue = 0)
    {
        var item = m_save.itemsFloat.Find(x => { return x.key == key; });
        if (item != null)
            return item.value;
        return defaultValue;
    }

    public bool getBool(string key, bool defaultValue = false)
    {
        var item = m_save.itemsBool.Find(x => { return x.key == key; });
        if (item != null)
            return item.value;
        return defaultValue;
    }

    public string getString(string key, string defaultValue = "")
    {
        var item = m_save.itemsString.Find(x => { return x.key == key; });
        if (item != null)
            return item.value;
        return defaultValue;
    }

    public void removeInt(string key)
    {
        m_save.itemsInt.RemoveAll(x => { return x.key == key; });
        save();
    }

    public void removeFloat(string key)
    {
        m_save.itemsFloat.RemoveAll(x => { return x.key == key; });
        save();
    }

    public void removeBool(string key)
    {
        m_save.itemsBool.RemoveAll(x => { return x.key == key; });
        save();
    }

    public void removeString(string key)
    {
        m_save.itemsString.RemoveAll(x => { return x.key == key; });
        save();
    }

    Save defaultSave()
    {
        var s = new Save();
        s.version = version;
        return s;
    }
}