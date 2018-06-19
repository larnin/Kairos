using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerOnEnter : TriggerBaseLogic {

	public override void onEnter(TriggerInteractionLogic entity)
	{
		transform.GetChild(0).gameObject.SetActive(true);
	}

	public override void onExit(TriggerInteractionLogic entity)
	{
		transform.GetChild(0).gameObject.SetActive(false);
	}

}
