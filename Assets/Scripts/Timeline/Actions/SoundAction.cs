using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundAction : BaseAction {

	public AudioClip audioClip;

	public override void trigger(GameObject obj)
	{
		obj.GetComponent<AudioSource>().clip = audioClip;
		obj.GetComponent<AudioSource>().Play();
	}

	public override void triggerEnd(GameObject obj)
	{
		obj.GetComponent<AudioSource>().Stop();
		obj.GetComponent<AudioSource>().clip = null;
	}
}
