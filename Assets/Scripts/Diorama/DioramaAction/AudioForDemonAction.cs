using UnityEngine;
using System.Collections;

public class AudioForDemonAction : BaseDioramaAction
{
	[SerializeField] AudioClip m_soundToPlay;
	[SerializeField] AudioSource m_source;

	public override void triggerBegin()
	{
        if (m_soundToPlay != null)
        {
            m_source.clip = m_soundToPlay;
            m_source.Play();
        }
    }

	public override void triggerEnd()
	{
		
	}
}
