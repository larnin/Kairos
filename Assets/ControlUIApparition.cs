using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ControlUIApparition : MonoBehaviour
{

	[SerializeField] GameObject m_controlsText;

	// Update is called once per frame
	void Update()
	{
		if (Input.GetButtonDown("UISwitch"))
        {
			m_controlsText.SetActive(!m_controlsText.activeSelf);
            if (m_controlsText.activeSelf)
                Event<ShowControlesEvent>.Broadcast(new ShowControlesEvent());
        }
	}
}
