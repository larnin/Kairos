using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class CameraLogic : MonoBehaviour
{
    [SerializeField] bool m_smooth = true;
    [ShowIf("m_smooth")]
    [SerializeField] Vector3 m_speedTarget;
    [ShowIf("m_smooth")]
    [SerializeField] Vector3 m_expTarget;
    [ShowIf("m_smooth")]
    [SerializeField] Vector3 m_speedPosition;
    [ShowIf("m_smooth")]
    [SerializeField] Vector3 m_expPosition;
    [ShowIf("m_smooth")]
    [SerializeField] Vector3 m_speedRotation;
    [ShowIf("m_smooth")]
    [SerializeField] Vector3 m_expRotation;

    Transform m_target;
    Vector3 offset;
    CameraOffsetInfos m_currentOffsetInfos = new CameraOffsetInfos();

    Vector3 m_oldRotation = new Vector3();
    Vector3 m_oldPosition = new Vector3();
    Vector3 m_oldTarget = new Vector3();

    private void Start()
    {
        m_target = transform.GetComponentInParent<FollowTargetCamera>().target;
        offset = transform.localPosition;
    }

    public void onUpdate()
    {
        var targetPos = m_target.transform.position;
        CameraOffsetInfos infos = new CameraOffsetInfos();
        foreach (var modifier in m_cameraModifiers)
            infos += modifier.check(targetPos);

        /*if (m_smooth)
            infos = smooth(infos);*/
        
        targetPos = transform.parent.position + infos.targetOffset;
        var pos = transform.parent.InverseTransformDirection(infos.positionOffset) + offset;
        pos = transform.parent.TransformPoint(pos);
        var rot = infos.eulerRotationOffset;
        if(m_smooth)
        {
            targetPos = smoothTarget(targetPos);
            pos = smoothPosition(pos);
            rot = smoothAngle(rot);
        }

        /*transform.localPosition = transform.parent.InverseTransformDirection(infos.positionOffset) + offset;
        transform.LookAt(targetPos);
        Debug.DrawRay(targetPos, Vector3.up, Color.blue, 1);
        transform.Rotate(infos.eulerRotationOffset);*/

        transform.position = pos;
        transform.LookAt(targetPos);
        transform.Rotate(rot);
    }

    Vector3 smoothTarget(Vector3 value)
    {
        m_oldTarget = lerp(m_oldTarget, value, Time.deltaTime, m_speedTarget, m_expTarget);
        return m_oldTarget;
    }

    Vector3 smoothPosition(Vector3 value)
    {
        m_oldPosition = lerp(m_oldPosition, value, Time.deltaTime, m_speedPosition, m_expPosition);
        return m_oldPosition;
    }

    Vector3 smoothAngle(Vector3 value)
    {
        m_oldRotation = lerp(m_oldRotation, value, Time.deltaTime, m_speedRotation, m_expRotation);
        return m_oldRotation;
    }

    CameraOffsetInfos smooth(CameraOffsetInfos infos)
    {
        CameraOffsetInfos newInfos = new CameraOffsetInfos();
        newInfos.positionOffset = lerp(m_currentOffsetInfos.positionOffset, infos.positionOffset, Time.deltaTime, m_speedPosition, m_expPosition);
        newInfos.targetOffset = lerp(m_currentOffsetInfos.targetOffset, infos.targetOffset, Time.deltaTime, m_speedTarget, m_expTarget);
        newInfos.eulerRotationOffset = lerp(m_currentOffsetInfos.eulerRotationOffset, infos.eulerRotationOffset, Time.deltaTime, m_speedRotation, m_expRotation);
        m_currentOffsetInfos = newInfos;

        return newInfos;
    }

    Vector3 lerp(Vector3 start, Vector3 end, float t, Vector3 speed, Vector3 exp)
    {
        return new Vector3(start.x + lerp((end.x - start.x) * speed.x, t, exp.x), start.y + lerp((end.y - start.y) * speed.y, t, exp.y), start.z + lerp((end.z - start.z) * speed.z, t, exp.z));
    }

    float lerp(float delta, float t, float exp)
    {
        return Mathf.Pow(delta, exp) * t;
    }

    public static void registerModifier(ICameraModifier modifier)
    {
        if(m_cameraModifiers.Contains(modifier))
        {
            Debug.LogError("Can't register a modifier that is already registered.");
            return;
        }

        m_cameraModifiers.Add(modifier);
    }

    public static void unregisterModifier(ICameraModifier modifier)
    {
        m_cameraModifiers.Remove(modifier);
    }

    static List<ICameraModifier> m_cameraModifiers = new List<ICameraModifier>();
}