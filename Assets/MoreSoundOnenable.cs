using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoreSoundOnenable : MonoBehaviour {


	[SerializeField] AudioSource m_fireaudio;
	// Use this for initialization
	void OnEnable () {
		m_fireaudio.volume *= 2;
	}

	void OnDisable()
	{
		m_fireaudio.volume /= 2;
	}
	
}
