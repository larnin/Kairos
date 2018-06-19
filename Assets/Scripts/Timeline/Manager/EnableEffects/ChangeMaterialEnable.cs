using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeMaterialEnable : MonoBehaviour {


	[SerializeField] SkinnedMeshRenderer m_skinnedMeshRenderer = null;
	[SerializeField] Material[] m_materials;

	Mesh m_oldMesh;
	Material[] m_oldMaterials;

	private void OnEnable()
	{
		if (m_skinnedMeshRenderer == null)
			return;

		m_oldMaterials = m_skinnedMeshRenderer.materials;

		if (m_materials.Length != 0)
			m_skinnedMeshRenderer.materials = m_materials;
	}

	private void OnDisable()
	{
		if (m_skinnedMeshRenderer == null)
			return;

		m_skinnedMeshRenderer.materials = m_oldMaterials;
	}

}
