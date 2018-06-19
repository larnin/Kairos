using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Scene2Placement : MonoBehaviour {

	[SerializeField] GameObject m_follet;
	[SerializeField] Vector3 m_position;

	// Use this for initialization
	void Start () {
		m_follet.transform.position = m_position;
	}
	
	void OnEnable () {
		m_follet.transform.position = m_position;
	}
}
