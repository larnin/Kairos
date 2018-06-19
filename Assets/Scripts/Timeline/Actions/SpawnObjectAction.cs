using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class SpawnObjectAction : BaseAction
{
    public GameObject m_prefab;
    public bool m_relativePosition;
    public Vector3 m_position;
    public bool m_relativeRotation;
    public Quaternion m_rotation;
    public bool m_destroyAtExit;
    [HorizontalGroup("Action", Width = 20)] [HideLabel]
    public bool m_executeAction;
    [HorizontalGroup("Action")] [EnableIf("m_executeAction")]
    public BaseAction m_objectAction;

    GameObject m_instanciatedObject;

    public override void trigger(GameObject obj)
    {
        if(m_prefab == null)
        {
            Debug.LogError("No prefab referenced in a spawn object action");
            return;
        }

        m_instanciatedObject = GameObject.Instantiate(m_prefab);
        if (m_relativePosition)
            m_instanciatedObject.transform.position = obj.transform.TransformPoint(m_position);
        else m_instanciatedObject.transform.position = m_position;
        if (m_relativeRotation)
            m_instanciatedObject.transform.rotation = Quaternion.Inverse(obj.transform.rotation) * m_rotation;
        else m_instanciatedObject.transform.rotation = m_rotation;
        if (m_executeAction && m_objectAction != null)
            m_objectAction.trigger(m_instanciatedObject);
    }

    public override void triggerEnd(GameObject obj)
    {
        if (m_destroyAtExit && m_instanciatedObject)
            GameObject.Destroy(m_instanciatedObject);
    }
}
