using UnityEngine;
using System.Collections;

public class ChangeCameraBackgroundColorOnEnable : MonoBehaviour
{

	[SerializeField] Camera m_camera;
	[SerializeField] Color m_colorToChange;
	Color m_color;

	private void OnEnable()
	{
		m_color = m_camera.backgroundColor;
		m_camera.backgroundColor = m_colorToChange;
	}

	private void OnDisable()
	{
		m_camera.backgroundColor = m_color;
	}

}
