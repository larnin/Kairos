using UnityEngine;
using System.Collections;

public class PlaysSoundAction : BaseAction
{

	public AudioClip m_sound;

	public override void trigger(GameObject obj)
	{
		if (obj.GetComponent<AudioSource>() != null)
		{
			if (m_sound !=null)
				obj.GetComponent<AudioSource>().clip = m_sound;

			obj.GetComponent<AudioSource>().Play();
		}
	}

}
