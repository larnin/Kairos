using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class shadowsBiasSavior : MonoBehaviour {

	public Light light;
	public float newBias;

	// Use this for initialization
	void Start () {

		light.shadowBias = newBias;

	}
	
	// Update is called once per frame
	void Update () {

		light.shadowBias = newBias;
	}
}
