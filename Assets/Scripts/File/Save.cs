using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

[Serializable]
public class Save
{
    [Serializable]
    public class ItemInt
    {
        public ItemInt(string _key, int _value)
        {
            key = _key;
            value = _value;
        }

        public string key;
        public int value;
    }

    [Serializable]
    public class ItemFloat
    {
        public ItemFloat(string _key, float _value)
        {
            key = _key;
            value = _value;
        }

        public string key;
        public float value;
    }

    [Serializable]
    public class ItemBool
    {
        public ItemBool(string _key, bool _value)
        {
            key = _key;
            value = _value;
        }

        public string key;
        public bool value;
    }

    [Serializable]
    public class ItemString
    {
        public ItemString(string _key, string _value)
        {
            key = _key;
            value = _value;
        }

        public string key;
        public string value;
    }

    public int version = 0;

    public List<ItemInt> itemsInt = new List<ItemInt>();
    public List<ItemFloat> itemsFloat = new List<ItemFloat>();
    public List<ItemBool> itemsBool = new List<ItemBool>();
    public List<ItemString> itemsString = new List<ItemString>();
}
