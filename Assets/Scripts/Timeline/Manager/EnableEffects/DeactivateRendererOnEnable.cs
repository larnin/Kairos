using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeactivateRendererOnEnable : MonoBehaviour {


	[SerializeField] SkinnedMeshRenderer m_skinnedMeshRenderer = null;


	private void OnEnable()
	{
		if (m_skinnedMeshRenderer == null)
			return;

		m_skinnedMeshRenderer.enabled = false;
	}

	// Update is called once per frame
	private void OnDisable()
	{
		if (m_skinnedMeshRenderer == null)
			return;

		m_skinnedMeshRenderer.enabled = true;
	}
}
