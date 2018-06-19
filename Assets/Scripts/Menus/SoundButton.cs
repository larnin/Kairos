using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.EventSystems;// Required when using Event data.

public class SoundButton : MonoBehaviour, ISelectHandler// required interface when using the OnSelect method.
{
    AudioSource m_audioButton;
	void Start()
	{
		m_audioButton = GameObject.Find("ButtonSound").GetComponent<AudioSource>();
        GetComponent<Button>().onClick.AddListener(onClic);
    }

	//Do this when the selectable UI object is selected.
	public void OnSelect(BaseEventData eventData)
	{
		m_audioButton.Play();
	}

    void onClic()
    {
		m_audioButton.transform.GetChild(0).gameObject.GetComponent<AudioSource>().Play();
    }
}
