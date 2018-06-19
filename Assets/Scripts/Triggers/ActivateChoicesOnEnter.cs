using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class ActivateChoicesOnEnter : TriggerBaseLogic
{

	[SerializeField] List<ObjectWithTheDemon2Logic> m_choices = new List<ObjectWithTheDemon2Logic>();

	public override void onEnter(TriggerInteractionLogic entity)
	{
		foreach (ObjectWithTheDemon2Logic choice in m_choices)
		{
			choice.enabled = true;
		}
	}

	public override void onExit(TriggerInteractionLogic entity)
	{
		foreach (ObjectWithTheDemon2Logic choice in m_choices)
		{
			choice.enabled = false;
		}
	}

}
