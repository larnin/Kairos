
using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class GenericShadowPoseAction : BaseAction
{
    public string m_animationName;

    public override void trigger(GameObject obj)
    {
        var animator = obj.GetComponent<Animator>();
        if (animator == null)
        {
            Debug.LogError("Can't find an animator component on the GameObject " + obj.name);
            return;
        }
        animator.SetTrigger(m_animationName);
    }
}
