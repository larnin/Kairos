using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class CorrespondingChoiceAndBalance : ScriptableObject
{
    [Serializable]
    public struct ChoiceBalance
    {
        public string property;
        public int value;
    } 

    public ChoiceBalance[] choices;

    public int computeCurrentValue()
    {
        int sum = 0;
        foreach (ChoiceBalance e in choices)
        {
            TimelineCondition.TimelineProperty P = SaveAttributes.getTimelineProperty(e.property);
            if(P.enabled)
            {
                sum += e.value;
            }
        }

        return sum;
    }
}

