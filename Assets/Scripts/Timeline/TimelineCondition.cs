using ExpressionParser;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using Sirenix.OdinInspector;

[Serializable]
public class TimelineCondition
{
    public struct TimelineProperty
    {
        public bool unlocked;
        public bool enabled;
    };

    [SerializeField] List<string> properties;
    [SerializeField] string conditionExpression;

    [Button("Test value")]
    void test()
    {
		Debug.Log(check());
    }

    public bool check()
    {
        var parser = new ExpressionParser.ExpressionParser();
        Expression exp = parser.EvaluateExpression(conditionExpression);

        foreach (var parameter in properties)
            exp.Parameters[parameter].Value = SaveAttributes.getTimelineProperty(parameter).enabled ? 1 : 0;

        return exp.Value != 0;
    }
}