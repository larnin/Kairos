using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ChangeBalanceCoherenceDioramaAction : BaseDioramaAction
{
    [SerializeField] float m_value;

	public override void triggerBegin()
	{
		
	}

	public override void triggerEnd()
    {
        Event<AddBalanceOfCoherenceValueEvent>.Broadcast(new AddBalanceOfCoherenceValueEvent(m_value > 0, Mathf.Abs(m_value)));
    }
}
