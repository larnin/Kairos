using UnityEngine;
using System.Collections;

public class ChangeFogColorOnEnable : MonoBehaviour
{

	[SerializeField] Color m_colorToChange;
	Color m_color;

	private void OnEnable()
	{
		m_color = RenderSettings.fogColor;
		RenderSettings.fogColor = m_colorToChange;
	}

	private void OnDisable()
	{
		RenderSettings.fogColor = m_color;
	}
}
