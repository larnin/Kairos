using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestSound : MonoBehaviour {

	[SerializeField] SoundManagerLogic m_soundManager;

	public void OnFolletFootstep(int i)
	{
		m_soundManager.OnFolletFootstep(i);
	}
}
