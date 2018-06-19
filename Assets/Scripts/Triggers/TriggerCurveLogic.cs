using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

[RequireComponent(typeof(BoxCollider))]
public class TriggerCurveLogic : TriggerBaseLogic
{
    public enum Axis
    {
        X,
        Y,
        Z
    }

    [SerializeField] Axis m_axis;
    [SerializeField] AnimationCurve m_curveX;
    [SerializeField] AnimationCurve m_curveY;
    [SerializeField] AnimationCurve m_curveZ;
    Coroutine m_coroutine;
    BoxCollider m_collider;

    private void Awake()
    {
        m_collider = GetComponent<BoxCollider>();
    }

    public override void onEnter(TriggerInteractionLogic entity)
    {
        m_coroutine = StartCoroutine(execCurveCoroutine(entity));
    }

    public override void onExit(TriggerInteractionLogic entity)
    {
        if (m_coroutine != null)
            StopCoroutine(m_coroutine);
    }

    IEnumerator execCurveCoroutine(TriggerInteractionLogic entity)
    {
        var transform = entity.transform;
        var colliderTransform = m_collider.transform;

        while(transform != null && colliderTransform != null)
        {
            var colliderMin = colliderTransform.TransformPoint(m_collider.center - m_collider.size / 2.0f);
            var colliderMax = colliderTransform.TransformPoint(m_collider.center + m_collider.size / 2.0f);
            float value = lerpValue(colliderMin, colliderMax, transform.position, m_axis);
            Debug.Log(value + " " + m_curveX.Evaluate(value) + " " + m_curveY.Evaluate(value) + " " + m_curveZ.Evaluate(value));

            yield return null;
        }
    }

    public static float lerpValue(Vector3 minV, Vector3 maxV, Vector3 posV, Axis axis)
    {
        float min = axis == Axis.X ? minV.x : axis == Axis.Y ? minV.y : minV.z;
        float max = axis == Axis.X ? maxV.x : axis == Axis.Y ? maxV.y : maxV.z;
        float pos = axis == Axis.X ? posV.x : axis == Axis.Y ? posV.y : posV.z;

        return (pos - min) / (max - min);
    }
}
