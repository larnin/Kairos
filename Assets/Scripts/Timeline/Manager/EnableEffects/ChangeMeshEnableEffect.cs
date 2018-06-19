using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using Sirenix.OdinInspector;

public class ChangeMeshEnableEffect : SerializedMonoBehaviour
{
    [SerializeField] MeshRenderer m_meshRenderer = null;
    [SerializeField] Mesh m_mesh = null;
    [SerializeField] Material[] m_materials;

    Mesh m_oldMesh;
    Material[] m_oldMaterials;

    private void OnEnable()
    {
        if (m_meshRenderer == null)
            return;

        MeshFilter meshFilter = m_meshRenderer.GetComponent<MeshFilter>();

        m_oldMesh = meshFilter.mesh;
        m_oldMaterials = m_meshRenderer.materials;

        meshFilter.mesh = m_mesh;
        if(m_materials.Length != 0)
            m_meshRenderer.materials = m_materials;
    }

    private void OnDisable()
    {
        if (m_meshRenderer == null)
            return;
        
        MeshFilter meshFilter = m_meshRenderer.GetComponent<MeshFilter>();

         meshFilter.mesh = m_oldMesh;
         m_meshRenderer.materials = m_oldMaterials;
    }
}