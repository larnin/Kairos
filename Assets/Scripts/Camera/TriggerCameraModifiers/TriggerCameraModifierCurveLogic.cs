using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using Sirenix.OdinInspector;

public class TriggerCameraModifierCurveLogic : TriggerCameraModifierBaseLogic
{
    public enum Axis
    {
        X,
        Y,
        Z
    }

    [ToggleGroup("m_offsetPosition", order: -1, groupTitle: "Position")]
    [SerializeField] bool m_offsetPosition = true;
    [ToggleGroup("m_offsetPosition")]
    [SerializeField] AnimationCurve m_curvePosX;
    [ToggleGroup("m_offsetPosition")]
    [SerializeField] AnimationCurve m_curvePosY;
    [ToggleGroup("m_offsetPosition")]
    [SerializeField] AnimationCurve m_curvePosZ;

    [ToggleGroup("m_offsetTarget", order: -1, groupTitle: "Target")]
    [SerializeField] bool m_offsetTarget = true;
    [ToggleGroup("m_offsetTarget")]
    [SerializeField] AnimationCurve m_curveTargetX;
    [ToggleGroup("m_offsetTarget")]
    [SerializeField] AnimationCurve m_curveTargetY;
    [ToggleGroup("m_offsetTarget")]
    [SerializeField] AnimationCurve m_curveTargetZ;

    [ToggleGroup("m_offsetRotation", order: -1, groupTitle: "Rotation")]
    [SerializeField] bool m_offsetRotation = true;
    [ToggleGroup("m_offsetRotation")]
    [SerializeField] AnimationCurve m_curveAngleX;
    [ToggleGroup("m_offsetRotation")]
    [SerializeField] AnimationCurve m_curveAngleY;
    [ToggleGroup("m_offsetRotation")]
    [SerializeField] AnimationCurve m_curveAngleZ;

    [SerializeField] Axis m_axis;
    
    public override CameraOffsetInfos check(Vector3 position)
    {
        var onColliderPos = transform.InverseTransformPoint(position);

        var colliderMin = m_collider.center - m_collider.size / 2.0f;
        var colliderMax = m_collider.center + m_collider.size / 2.0f;

        if(onColliderPos.x < colliderMin.x || onColliderPos.x > colliderMax.x
            || onColliderPos.y < colliderMin.y || onColliderPos.y > colliderMax.y
            || onColliderPos.z < colliderMin.z || onColliderPos.z > colliderMax.z)
            return new CameraOffsetInfos();

        float value = lerpValue(colliderMin, colliderMax, onColliderPos, m_axis);
        if (value < 0 || value > 1)
            return new CameraOffsetInfos();

        CameraOffsetInfos infos = new CameraOffsetInfos();
        if (m_offsetPosition)
            infos.positionOffset = new Vector3(m_curvePosX.Evaluate(value), m_curvePosY.Evaluate(value), m_curvePosZ.Evaluate(value));
        if (m_offsetTarget)
            infos.targetOffset = new Vector3(m_curveTargetX.Evaluate(value), m_curveTargetY.Evaluate(value), m_curveTargetZ.Evaluate(value));
        if (m_offsetRotation)
            infos.eulerRotationOffset = new Vector3(m_curveAngleX.Evaluate(value), m_curveAngleY.Evaluate(value), m_curveAngleZ.Evaluate(value));

        return infos;
    }

    public override CameraOffsetInfos checkUnclamped(Vector3 position)
    {
        var onColliderPos = transform.InverseTransformPoint(position);

        var colliderMin = m_collider.center - m_collider.size / 2.0f;
        var colliderMax = m_collider.center + m_collider.size / 2.0f;

        float value = lerpValue(colliderMin, colliderMax, onColliderPos, m_axis);
        value = Mathf.Clamp01(value);

        CameraOffsetInfos infos = new CameraOffsetInfos();
        if (m_offsetPosition)
            infos.positionOffset = new Vector3(m_curvePosX.Evaluate(value), m_curvePosY.Evaluate(value), m_curvePosZ.Evaluate(value));
        if (m_offsetTarget)
            infos.targetOffset = new Vector3(m_curveTargetX.Evaluate(value), m_curveTargetY.Evaluate(value), m_curveTargetZ.Evaluate(value));
        if (m_offsetRotation)
            infos.eulerRotationOffset = new Vector3(m_curveAngleX.Evaluate(value), m_curveAngleY.Evaluate(value), m_curveAngleZ.Evaluate(value));

        return infos;
    }

    float lerpValue(Vector3 minV, Vector3 maxV, Vector3 posV, Axis axis)
    {
        float min = axis == Axis.X ? minV.x : axis == Axis.Y ? minV.y : minV.z;
        float max = axis == Axis.X ? maxV.x : axis == Axis.Y ? maxV.y : maxV.z;
        float pos = axis == Axis.X ? posV.x : axis == Axis.Y ? posV.y : posV.z;

        return (pos - min) / (max - min);
    }

    
}