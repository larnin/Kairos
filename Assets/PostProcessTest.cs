using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PostProcessing;

public class PostProcessTest : MonoBehaviour {

	public PostProcessingProfile ppp;
	public Material pppMat;

	private float timer = 0;
	private ChromaticAberrationModel.Settings chromSet;

	// Use this for initialization
	void Start () {
		//ppp.chromaticAberration.settings
		chromSet = ppp.chromaticAberration.settings;
		chromSet.intensity = 0;
		ppp.chromaticAberration.settings = chromSet;
		pppMat.SetFloat("_FastForward",0);
	}
	
	// Update is called once per frame
	void Update () {
		if (Input.GetKeyUp ("a")) {
			timer = 0;
			StartCoroutine("FastForward");
		}
		if (Input.GetKeyUp ("b")) {
			timer = 0;
			StartCoroutine("Rewind");
		}
	}

	IEnumerator FastForward(){
		while (timer <= 1) {
			timer += Time.deltaTime;
			pppMat.SetFloat ("_Sens", 1);
			pppMat.SetFloat("_FastForward",Mathf.Lerp(0,1,timer));
			chromSet.intensity = Mathf.Lerp (0, 1, timer);
			ppp.chromaticAberration.settings = chromSet;
			yield return new WaitForFixedUpdate();
		}
		yield return new WaitForFixedUpdate();
	}

	IEnumerator Rewind(){
		while (timer <= 1) {
			timer += Time.deltaTime;
			pppMat.SetFloat("_FastForward",Mathf.Lerp(0,1,timer));
			pppMat.SetFloat ("_Sens", 0);
			chromSet.intensity = Mathf.Lerp (0, 1, timer);
			ppp.chromaticAberration.settings = chromSet;
			yield return new WaitForFixedUpdate();
		}
		yield return new WaitForFixedUpdate();
	}
}
