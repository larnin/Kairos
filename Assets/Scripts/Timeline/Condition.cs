using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

[Serializable]
public class Condition
{
    [SerializeField] string m_propertyName;
    [SerializeField] ConditionType m_conditionType;

    [HorizontalGroup("Values")]
    [SerializeField]
    double m_value1;
    [HorizontalGroup("Values")]
    [ShowIf("enableSecondValue")]
    [SerializeField]
    double m_value2;

    public enum ConditionType
    {
        SUPERIOR,
        SUPERIOR_OR_EQUAL,
        INFERIOR,
        INFERIOR_OR_EQUAL,
        EQUAL,
        INEQUAL,
        BETWEEN,
        OUTSIDE
    }

    bool enableSecondValue()
    {
        return m_conditionType == ConditionType.BETWEEN || m_conditionType == ConditionType.OUTSIDE;
    }

    bool checkProperty(double value)
    {
        switch (m_conditionType)
        {
            case ConditionType.BETWEEN:
                return value >= Math.Min(m_value1, m_value2) && value <= Math.Max(m_value1, m_value2);
            case ConditionType.EQUAL:
                return value == m_value1;
            case ConditionType.INEQUAL:
                return value != m_value1;
            case ConditionType.INFERIOR:
                return value < m_value1;
            case ConditionType.INFERIOR_OR_EQUAL:
                return value <= m_value1;
            case ConditionType.OUTSIDE:
                return value < Math.Min(m_value1, m_value2) || value > Math.Max(m_value1, m_value2);
            case ConditionType.SUPERIOR:
                return value > m_value1;
            case ConditionType.SUPERIOR_OR_EQUAL:
                return value >= m_value1;
            default:
                return false;
        }
    }

    public bool check()
    {
        return checkProperty(PropertyLogic.get(m_propertyName));
    }
}
