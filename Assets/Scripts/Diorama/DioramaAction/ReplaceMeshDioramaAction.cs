using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ReplaceMeshDioramaAction : BaseDioramaAction
{
    [SerializeField] MeshFilter m_meshFilter;
    [SerializeField] Mesh m_newMesh;

	public override void triggerBegin()
	{
		
	}

	public override void triggerEnd()
    {
        if (m_meshFilter == null)
        {
            Debug.LogError("No mesh renderer selected!");
            return;
        }

        if (m_newMesh == null)
        {
            Debug.LogError("No mesh selected!");
            return;
        }

        m_meshFilter.sharedMesh = m_newMesh;
    }

}
