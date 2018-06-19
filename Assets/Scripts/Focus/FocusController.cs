using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FocusController : MonoBehaviour {

	public Material postProcessMat; 
	public Light[] sceneLights;
	public GameObject[] interactables;

	public float transitionSpeed;

	private float timer = 0;
	private bool focus = false;
	public Color[] lightColor; 

	// Use this for initialization
	void Start () {

		for(int i = 0; i < sceneLights.Length; i++){
			lightColor[i] = sceneLights[i].color;
		}

		for(int i = 0; i < interactables.Length; i++){
			interactables[i].GetComponent<Renderer> ().material.SetColor ("_GlowColor", Color.black);
		}

		postProcessMat.SetFloat ("_Focus", 0);
	}
	
	// Update is called once per frame
	void Update () {

		if (Input.GetKeyUp ("a")) {

			if (focus == false) {
				StartCoroutine ("StartFocus");
			} 
			else if (focus == true) {
				StartCoroutine ("EndFocus");
			}
		}
	}

	IEnumerator StartFocus ()
	{
		timer = 0;
		while(timer < 1)
		{
			timer+= Time.deltaTime * transitionSpeed;
			postProcessMat.SetFloat("_Focus",Mathf.Lerp(0,1,timer));

			for(int i = 0; i < sceneLights.Length; i++){
				sceneLights[i].color = Color.Lerp(lightColor[i],Color.white,timer);
			}

			for(int i = 0; i < interactables.Length; i++){
				interactables[i].GetComponent<Renderer> ().material.SetColor ("_GlowColor", Color.Lerp(Color.black,Color.white,timer));
			}

			yield return null;
		}
		focus = true;
		yield return null;
	}

	IEnumerator EndFocus ()
	{
		timer = 0;
		while(timer < 1)
		{
			timer+= Time.deltaTime * transitionSpeed;
			postProcessMat.SetFloat("_Focus",Mathf.Lerp(1,0,timer));

			for(int i = 0; i < sceneLights.Length; i++){
				sceneLights[i].color = Color.Lerp(Color.white,lightColor[i],timer);
			}
			for(int i = 0; i < interactables.Length; i++){
				interactables[i].GetComponent<Renderer> ().material.SetColor ("_GlowColor", Color.Lerp(Color.white,Color.black,timer));
			}

			yield return null;
		}
		focus = false;
		yield return null;
	}
}
