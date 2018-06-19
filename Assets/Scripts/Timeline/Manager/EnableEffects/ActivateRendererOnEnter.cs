using UnityEngine;
using System.Collections;

public class ActivateRendererOnEnter : MonoBehaviour
{

	[SerializeField] SkinnedMeshRenderer m_skinnedMesh;

	private void OnTriggerEnter()
	{
		if (m_skinnedMesh == null)
			return;

		m_skinnedMesh.enabled = true;
	
	}

}
