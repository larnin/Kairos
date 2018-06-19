using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ConditionalAction : BaseAction
{
    [SerializeField] Condition m_condition = new Condition();

    public BaseAction m_action;

    public override void trigger(GameObject obj)
    {
        if(m_action == null)
        {
            Debug.LogError("Null action in a conditional action");
            return;
        }

        if (m_condition.check())
            m_action.trigger(obj);
    }
}
