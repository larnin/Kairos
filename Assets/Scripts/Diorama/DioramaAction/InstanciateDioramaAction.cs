using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class InstanciateDioramaAction : BaseDioramaAction
{
    [SerializeField] Transform m_parent;
    [SerializeField] GameObject m_prefab;
    [HideIf("parentNull")]
    [SerializeField] bool m_isChild;
    [HideIf("m_isChild")] [HideIf("parentNull")]
    [SerializeField] bool m_isRelative;
    [SerializeField] Vector3 m_offset;

    bool parentNull()
    {
        return m_parent == null;
    }

	public override void triggerBegin()
	{

	}

	public override void triggerEnd()
    {
        if(m_prefab == null)
        {
            Debug.LogError("Prefab null!");
            return; 
        }
        if((m_isChild || m_isRelative) && m_parent == null)
        {
            Debug.LogError("Can't make a relatif or child object without a parent!");
            return;
        }

        var obj = GameObject.Instantiate(m_prefab);
        if (m_isChild)
        {
            obj.transform.parent = m_parent.transform;
            obj.transform.localPosition = m_offset;
        }
        else if (m_isRelative)
        {
            obj.transform.position = m_parent.transform.position + m_offset;
        }
        else obj.transform.position = m_offset;
    }
}
