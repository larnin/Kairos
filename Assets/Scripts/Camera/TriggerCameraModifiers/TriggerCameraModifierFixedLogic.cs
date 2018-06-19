using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class TriggerCameraModifierFixedLogic : TriggerCameraModifierBaseLogic
{
    [SerializeField] Transform m_fixedTargetPosition;
    [SerializeField] bool m_targetPlayer;
    [ShowIf("m_targetPlayer")]
    [SerializeField] Vector3 m_targetOffset;

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
        var delta = position - m_fixedTargetPosition.position;
        var infos = new CameraOffsetInfos();
        infos.positionOffset = -delta;
        infos.targetOffset = m_targetPlayer ? m_targetOffset : - delta;
        infos.eulerRotationOffset = m_fixedTargetPosition.transform.rotation.eulerAngles;

        return infos;
    }
}