using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using DG.Tweening;

public class TransformAction : BaseAction
{
    const float moveDuration = 0.6f;
    const float fadeDuration = 0.2f;

    [PropertyOrder(-1)]
    public bool m_targetTransform;
    [PropertyOrder(-1)]
    public Transform m_transform;
    [HorizontalGroup("Position", Width = 20)] [HideLabel]
    public bool m_changePosition;
    [HorizontalGroup("Position")] [EnableIf("m_changePosition")]
    public Vector3 m_position;
    [HorizontalGroup("Rotation", Width = 20)] [HideLabel]
    public bool m_changeRotation;
    [HorizontalGroup("Rotation")] [EnableIf("m_changeRotation")]
    public Quaternion m_rotation;
    public bool m_instantMove = false;

    [HideInInspector]
    public string m_gameobjectName = "";

    [OnInspectorGUI]
    void updateObj()
    {
        if(m_transform == null)
        {
            if (m_gameobjectName == null || m_gameobjectName.Length == 0)
                return;

            findObject();
            if (m_transform == null)
                return;
        }
        else m_gameobjectName = m_transform.gameObject.GetFullName();
    }

    [PropertyOrder(-1)]
    [HorizontalGroup("buttons")]
    [Button("CopieValues")]
    void copieTransformValues()
    {
        if (m_transform == null)
        {
            findObject();
            if (m_transform == null)
            {
                Debug.LogError("Unable to find the referenced transform !");
                return;
            }
        }

        m_position = m_transform.position;
        m_rotation = m_transform.rotation;
    }

    [PropertyOrder(-1)]
    [HorizontalGroup("buttons")]
    [Button("CopieLocalValues")]
    void copielocalTransformValues()
    {
        if (m_transform == null)
        {
            findObject();
            if (m_transform == null)
            {
                Debug.LogError("Unable to find the referenced transform !");
                return;
            }
        }

        m_position = m_transform.localPosition;
        m_rotation = m_transform.localRotation;
    }

    public override void trigger(GameObject obj)
    {
        if (m_targetTransform)
            jumpToTransform(obj);
        else jumpToPosition(obj);
    }

    void jumpToTransform(GameObject obj)
    {
        updateObj();

        if(m_transform == null)
        {
            Debug.LogError("Unable to find the targeted object " + m_gameobjectName);
            jumpToPosition(obj);
            return;
        }
        Vector3 pos = m_transform.position;
        Quaternion rot = obj.transform.rotation;

        var comp = m_transform.GetComponent<ShadowLerpMoveLogic>();
        if (comp != null)
        {
            pos = comp.getTargetPosition();
            rot = comp.getTargetRotation();
        }

        if (m_changePosition)
            pos += m_position;
        if (m_changeRotation)
            rot = m_rotation;
        else rot = m_transform.rotation;

        moveTo(obj, pos, rot);
    }

    void jumpToPosition(GameObject obj)
    {
        Vector3 pos = obj.transform.position;
        Quaternion rot = obj.transform.rotation;

        if (m_changePosition)
           pos = m_position;
        if (m_changeRotation)
            rot = m_rotation;

        moveTo(obj, pos, rot);
    }

    void moveTo(GameObject obj, Vector3 pos, Quaternion rot)
    {
        if (moveDuration < 2 * fadeDuration)
        {
            Debug.LogError("Move duration must be at least 2* fade duration");
            instantMove(obj, pos, rot);
            return;
        }

        var comp = obj.GetComponent<ShadowLerpMoveLogic>();
        if (comp != null && !m_instantMove)
            comp.moveTo(pos, rot, moveDuration, fadeDuration);
        else instantMove(obj, pos, rot);
    }

    void instantMove(GameObject obj, Vector3 pos, Quaternion rot)
    {
        obj.transform.position = pos;
        obj.transform.rotation = rot;
    }

    void findObject()
    {
        var obj = GameObject.Find(m_gameobjectName);
        if (obj != null)
            m_transform = obj.transform;
    }
}

