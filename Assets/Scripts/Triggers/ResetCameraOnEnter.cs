using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResetCameraOnEnter : TriggerBaseLogic
{
	[SerializeField] ChangeCameraOnEnable m_script;

	public override void onEnter(TriggerInteractionLogic entity)
	{
		m_script.DisableScript();
	}

	public override void onExit(TriggerInteractionLogic entity)
	{
	}

}
