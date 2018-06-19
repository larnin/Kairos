using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Trailer_OpenEye : MonoBehaviour {

    public GameObject Hand = null;
    
	private Animator animator;
	public Animator camAnim;
	public Material[] mats;
	public Material eyeMat;
	public float apparitionSpeed;
	public Light demonLight;
	//public Light demonLight2;
	public Light demonLight3;
	public Light eyeLight;

	private float timer = 0;
	private float timer2 = 0;

    public float DelayHand = 0f;
    public float delayOpeningEyes = 0f;
    public float delayApparation = 0f;
    public float delayApparitionLights = 0f;


    // Use this for initialization
    void Start () {
        animator = GetComponent<Animator>();
        for (int i = 0; i < mats.Length; i++)
        {

            mats[i].SetFloat("_Apparition", 0);
        }
        demonLight.intensity = 0;
       // demonLight2.intensity = 0;
        demonLight3.intensity = 0;
        eyeLight.intensity = 0;
        eyeMat.SetFloat("_Expression", 0);
		RenderSettings.fogEndDistance = 90;

        //  StartCoroutine

        StartCoroutine(delayHand());
        StartCoroutine(openingEyes());
        StartCoroutine(Apparition());
        StartCoroutine(ApparitionLights());

    }

    IEnumerator delayHand()
    {
        yield return new WaitForSeconds(DelayHand);
        Hand.SetActive(true);
    }

   IEnumerator openingEyes()
    {
        yield return new WaitForSeconds(delayOpeningEyes);
        eyeMat.SetFloat("_Expression", 1);
        animator.SetBool("open", true);
    }
    

	IEnumerator Apparition(){

        yield return new WaitForSeconds(delayApparation);
        
        while (timer * apparitionSpeed < 1) {
		
			timer += Time.deltaTime;
			for (int i = 0; i < mats.Length; i++) {
			
				mats [i].SetFloat ("_Apparition", Mathf.Lerp (0, 1, timer * apparitionSpeed));
			}
			RenderSettings.fogEndDistance = Mathf.Lerp (90, 150, timer * apparitionSpeed);
			yield return new WaitForFixedUpdate ();
		}
		yield return new WaitForFixedUpdate ();
	}

	IEnumerator ApparitionLights(){

        yield return new WaitForSeconds(delayApparitionLights);

        while (timer * apparitionSpeed *2 < 1) {

			demonLight.intensity = Mathf.Lerp (0, 3, timer * apparitionSpeed*2);
			//demonLight2.intensity = Mathf.Lerp (0, 7, timer * apparitionSpeed*2);
			demonLight3.intensity = Mathf.Lerp (0, 5, timer * apparitionSpeed*2);
			eyeLight.intensity = Mathf.Lerp (0, 7, timer * apparitionSpeed*2);
			yield return new WaitForFixedUpdate ();
		}
		yield return new WaitForFixedUpdate ();
	}

	IEnumerator ChangeEye(){

		while (timer2 < 1) {

			timer2 += Time.deltaTime;
			eyeMat.SetFloat ("_Expression", Mathf.Lerp (0, 1, timer2));
			yield return new WaitForFixedUpdate ();
		}
		yield return new WaitForFixedUpdate ();
	}
}
