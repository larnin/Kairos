using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.Collections.Generic;

public class SoundOnButtonSelect : MonoBehaviour
{
	Button[] m_buttonArray;

	void Start()
	{
		m_buttonArray = GetComponentsInChildren<Button>(true);
		foreach (Button button in m_buttonArray)
		{
			button.gameObject.AddComponent<SoundButton>();
		}
	}

	// Update is called once per frame
	void Update()
	{

	}
}
