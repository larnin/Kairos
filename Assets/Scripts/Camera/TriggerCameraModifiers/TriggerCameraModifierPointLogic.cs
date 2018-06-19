using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class TriggerCameraModifierPointLogic : TriggerCameraModifierBaseLogic
{
    [ToggleGroup("m_offsetPosition", order: -1, groupTitle: "Position")]
    [SerializeField] bool m_offsetPosition = true;
    [ToggleGroup("m_offsetPosition")]
    [SerializeField] float m_posX;
    [ToggleGroup("m_offsetPosition")]
    [SerializeField] float m_posY;
    [ToggleGroup("m_offsetPosition")]
    [SerializeField] float m_posZ;

    [ToggleGroup("m_offsetTarget", order: -1, groupTitle: "Target")]
    [SerializeField] bool m_offsetTarget = true;
    [ToggleGroup("m_offsetTarget")]
    [SerializeField] float m_targetX;
    [ToggleGroup("m_offsetTarget")]
    [SerializeField] float m_targetY;
    [ToggleGroup("m_offsetTarget")]
    [SerializeField] float m_targetZ;

    [ToggleGroup("m_offsetRotation", order: -1, groupTitle: "Rotation")]
    [SerializeField] bool m_offsetRotation = true;
    [ToggleGroup("m_offsetRotation")]
    [SerializeField] float m_angleX;
    [ToggleGroup("m_offsetRotation")]
    [SerializeField] float m_angleY;
    [ToggleGroup("m_offsetRotation")]
    [SerializeField] float m_angleZ;

    public override CameraOffsetInfos check(Vector3 position)
    {
        var onColliderPos = transform.InverseTransformPoint(position);

        var colliderMin = m_collider.center - m_collider.size / 2.0f;
        var colliderMax = m_collider.center + m_collider.size / 2.0f;

        if (onColliderPos.x < colliderMin.x || onColliderPos.x > colliderMax.x
            || onColliderPos.y < colliderMin.y || onColliderPos.y > colliderMax.y
            || onColliderPos.z < colliderMin.z || onColliderPos.z > colliderMax.z)
            return new CameraOffsetInfos();

        return checkUnclamped(position);
    }

    public override CameraOffsetInfos checkUnclamped(Vector3 position)
    {
        var c = new CameraOffsetInfos();
        if (m_offsetRotation)
            c.eulerRotationOffset = new Vector3(m_angleX, m_angleY, m_angleZ);
        if (m_offsetPosition)
            c.positionOffset = new Vector3(m_posX, m_posY, m_posZ);
        if (m_offsetTarget)
            c.targetOffset = new Vector3(m_targetX, m_targetY, m_targetZ);
        return c;
    }
}
