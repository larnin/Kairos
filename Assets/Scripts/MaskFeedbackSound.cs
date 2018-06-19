using UnityEngine;
using System.Collections;

public class MaskFeedbackSound : MonoBehaviour
{
	SubscriberList m_subscriberList = new SubscriberList();
	[SerializeField] AudioClip m_goodAnswer;
	[SerializeField] AudioClip m_badAnswer;


	// Use this for initialization
	void Start()
	{
		m_subscriberList.Add(new Event<MaskSelectedEvent>.Subscriber(MaskFeedback));
		m_subscriberList.Subscribe();

	}

	void MaskFeedback(MaskSelectedEvent e)
	{
		Debug.Log("MARRE");

		if (e.valid)
			GetComponent<AudioSource>().clip = m_goodAnswer;
		else
			GetComponent<AudioSource>().clip = m_badAnswer;

		GetComponent<AudioSource>().Play();
	}

	private void OnDestroy()
	{
		m_subscriberList.Unsubscribe();
	}
}
