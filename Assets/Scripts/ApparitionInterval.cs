using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ApparitionInterval : MonoBehaviour {

	public List<GameObject> hands = new List<GameObject>();
	//public float waitToStart = 0;
	public float intervalle = 1;

	// Use this for initialization
	void Start () {
		//StartCoroutine(MakeHandsAppear());
	}

	void OnEnable(){

		StartCoroutine("MakeHandsAppear");

	}

	IEnumerator MakeHandsAppear()
	{
		//yield return new WaitForSeconds(waitToStart);
		for (int i = 0; i < hands.Count; i++)
		{
			hands[i].SetActive(true);
			yield return new WaitForSeconds(intervalle);
		}
	}
	

}
