using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using DG.Tweening;

public class DelayedAction : BaseAction
{
    public float m_time;
    public BaseAction m_action;

    public override void trigger(GameObject obj)
    {
        if (m_action == null)
        {
            Debug.LogError("Null action in a DelayedAction");
            return;
        }

        DOVirtual.DelayedCall(m_time, ()=>{ m_action.trigger(obj); });
    }
}
