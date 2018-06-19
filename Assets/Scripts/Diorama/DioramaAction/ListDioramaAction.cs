using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ListDioramaAction : BaseDioramaAction
{
    [SerializeField] List<BaseDioramaAction> m_actions = new List<BaseDioramaAction>();

    public override void triggerEnd()
    {
        foreach(var a in m_actions)
        {
            if(a == null)
            {
                Debug.LogError("Null action in the list!");
                continue;
            }
            a.triggerEnd();
        }
    }

	public override void triggerBegin()
	{
		foreach (var a in m_actions)
		{
			if (a == null)
			{
				Debug.LogError("Null action in the list!");
				continue;
			}
			a.triggerBegin();
		}
	}
}