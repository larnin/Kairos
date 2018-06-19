using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class trailer_app : MonoBehaviour {

	public Material appMat;
	public float speed;
	private float timer = 0;

	// Use this for initialization
	void Start () {
		appMat.SetFloat ("_Apparition", 1);
	}
	
	// Update is called once per frame
	void Update () {
		if (Input.GetKeyUp ("j")) {
		
			timer = 0;
			StartCoroutine ("Apparition");
		}
	}

	IEnumerator Apparition(){
	
		while (timer * speed < 1) {
		
			timer += Time.deltaTime;
			appMat.SetFloat ("_Apparition", Mathf.Lerp (1, 0, timer * speed));
			yield return new WaitForFixedUpdate ();
		}
		yield return new WaitForFixedUpdate ();
	}
}
