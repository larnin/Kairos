using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using DG.Tweening;

public class ChangeCameraOnEnable : MonoBehaviour {

	//[SerializeField] CinemachineVirtualCamera m_camera;
	[SerializeField] CinemachineVirtualCamera m_camera;
	[SerializeField] int m_priority = 100;
	[SerializeField] float m_fogDistanceOriginal;
	[SerializeField] float m_fogDistanceToSet;
	[SerializeField] BalanceOfCoherenceLogic m_balance;

	void OnEnable () {

		if (m_balance.balanceValue > m_balance.balanceMinValue)
		{
			m_camera.Priority = m_priority;
			RenderSettings.fogEndDistance = m_fogDistanceToSet;
		}
	}

	public void DisableScript()
	{
		m_camera.Priority = 0;
		RenderSettings.fogEndDistance = m_fogDistanceOriginal;
		enabled = false;
	}


}
