using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ShadowPoseAction : BaseAction
{
    [ValueDropdown("getAnimationsTypes")]
    public int m_animationID;

    private ValueDropdownList<int> getAnimationsTypes()
    {
        return new ValueDropdownList<int>
        {
            { "1-1-ArmsCrossed", 101 },
            { "1-2-HittingWithLash1", 102 },
            { "1-3-HittingWithLash2Chair", 103 },
            { "1-4-HoldHands", 104 },
            { "1-5-SittingHoldinghands", 105 },
            { "1-6-WalksHandsLeft1", 106 },
            { "1-7-WalksHandsRight1", 107 },
            { "1-8-WalksHandsMiddle1", 108 },
            { "1-9-WalksHandsLeft2", 109 },
            { "1-10-WalkHandsRight2", 110 },
            { "1-11-WalkHandsMuddle2", 111 },

			{ "2-4-SitHurt2", 204 },
            { "2-5-SitthingHit1", 205 },
            { "2-6-KneeHit1", 206 },
            { "2-7-HittingWithLash2Ground", 207 },
            { "2-7-KneeHit2", 2072 },
            { "2-8-Stomping1", 208 },
            { "2-9-Stomping2", 209 },
            { "2-10-Kicking1", 210 },
            { "2-11-Kicking2", 211 },
            { "2-12-Lying1", 212 },
            { "2-13-Lying2", 213 },
            { "2-14-CarryUnconscious", 214 },
            { "2-15-CarryLeft1", 215 },
            { "2-16-CarryRight1", 216 },
            { "2-17-CarryLeft2", 217 },
            { "2-17-CarryRight2", 2172 },
        };
    }

    public override void trigger(GameObject obj)
    {
        var animator = obj.GetComponent<Animator>();
        if(animator == null)
        {
            Debug.LogError("Can't find an animator component on the GameObject " + obj.name);
            return;
        }
        animator.SetInteger("State", m_animationID);
    }
}
