using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeLightCookie : MonoBehaviour {

	[SerializeField]  public GameObject WindowLight;
	[SerializeField]  public Texture lightCookie;

	// Use this for initialization
	void OnEnable()
	{
		WindowLight.GetComponent<Light>().cookie = lightCookie;
	}

}
