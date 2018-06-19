using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class MultipleAction : BaseAction
{
    public List<BaseAction> m_actions = new List<BaseAction>();

    public override void trigger(GameObject obj)
    {
        if (m_actions == null)
        {
            Debug.LogError("Null action list in a MultipleAction");
            return;
        }

        foreach (var a in m_actions)
        {
            if(a == null)
            {
                Debug.LogError("Null action in a MultipleAction");
                continue;
            }
            a.trigger(obj);
        }
    }
}