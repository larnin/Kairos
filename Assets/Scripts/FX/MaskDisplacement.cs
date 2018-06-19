using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaskDisplacement : MonoBehaviour {

	public float moveSpeed;
	public float moveAmplitude;
	public Transform player;
    
    private float offset;
	private float variation;

	// Use this for initialization
	void Start () {
		offset = Random.Range (0, 20);
		variation = Random.Range (0.75f, 1.25f);
	}
	
	// Update is called once per frame
	void Update () {

		transform.Translate(Vector3.up*(moveAmplitude*variation) * Mathf.Sin (Time.time * (moveSpeed*variation)+offset));
		transform.LookAt (player);
		transform.rotation = Quaternion.Euler (0, transform.rotation.eulerAngles.y, 0);

	}
}
