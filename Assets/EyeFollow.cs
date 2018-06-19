using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EyeFollow : MonoBehaviour {

	[SerializeField] GameObject m_follet;
	
	// Update is called once per frame
	void Update () {
		transform.LookAt(m_follet.transform);
	}
}
