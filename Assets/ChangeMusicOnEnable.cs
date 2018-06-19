using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeMusicOnEnable : MonoBehaviour {

	[SerializeField] MusiqueManager m_music;
	[SerializeField] bool m_dontDisable = false;
	[SerializeField] bool m_changeVolume = false;
	[SerializeField] float m_newVolume;

	void OnEnable()
	{
		m_music.TransitionMusic(m_changeVolume, m_newVolume);
	}

    private void OnDisable()
    {
		if (m_dontDisable == false)
			m_music.GoBack();
    }
}
