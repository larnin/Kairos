
using ExpressionParser;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using Sirenix.OdinInspector;

[Serializable]
public class TimelineCondition2
{
    public struct TimelineProperty
    {
        public bool unlocked;
        public bool enabled;
    };

    [ValueDropdown("getProperties")]
    [SerializeField] List<string> m_properties;
    [SerializeField] string m_conditionExpression;

    [Button("Test value")]
    void test()
    {
        Debug.Log(check());
    }

    public bool check()
    {
        var parser = new ExpressionParser.ExpressionParser();
        Expression exp = parser.EvaluateExpression(m_conditionExpression);

        foreach (var parameter in m_properties)
            exp.Parameters[parameter].Value = SaveAttributes.getTimelineProperty(parameter).enabled ? 1 : 0;

        return exp.Value != 0;
    }

    List<string> getProperties()
    {
        var t = TimelineManager2Logic.instance();
        if (t == null)
            return null;
        return t.properties;
    }
}