using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ReplaceSkinnedMeshRendererDioramaAction : BaseDioramaAction
{
    [SerializeField] SkinnedMeshRenderer m_meshRenderer;
    [SerializeField] Mesh m_newMesh;

	public override void triggerBegin()
	{

	}

    public override void triggerEnd()
    {
        if(m_meshRenderer == null)
        {
            Debug.LogError("No mesh renderer selected!");
            return;
        }

        if(m_newMesh == null)
        {
            Debug.LogError("No mesh selected!");
            return;
        }

        m_meshRenderer.sharedMesh = m_newMesh;
    }
}
