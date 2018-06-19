using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowSittingBehaviour : MonoBehaviour {

	private Animator anim;
	private float rand_size;

	public int anim_nb;

	// Use this for initialization
	void Start () {
		anim = GetComponent<Animator> ();
		anim.SetInteger ("Pose", (int)Random.Range (0, anim_nb));
		rand_size = Random.Range (0.9f, 1.25f);
		transform.localScale = new Vector3 (rand_size, rand_size, rand_size);
	}
}
