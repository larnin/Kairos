using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class LoopForLamp : MonoBehaviour {

	AudioSource m_audio;

	// Use this for initialization
	void Start () {
		
		m_audio = GetComponent<AudioSource>();
		DOVirtual.DelayedCall(m_audio.clip.length - 1, () => restartSound());
	}

	void restartSound()
	{
		if (m_audio == null)
			return;	

		m_audio.time = 4;
		DOVirtual.DelayedCall(m_audio.clip.length - 5, () => restartSound());
	}
}
