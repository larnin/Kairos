using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

[RequireComponent(typeof(BoxCollider))]
public abstract class TriggerCameraModifierBaseLogic : TriggerBaseLogic, ICameraModifier
{
    protected BoxCollider m_collider;

    private void Awake()
    {
        m_collider = GetComponent<BoxCollider>();
    }

    public virtual void onAwake()
    {

    }

    public override void onEnter(TriggerInteractionLogic entity)
    {
        CameraLogic.registerModifier(this);
    }

    public override void onExit(TriggerInteractionLogic entity)
    {
        CameraLogic.unregisterModifier(this);
    }

    private void OnDestroy()
    {
        CameraLogic.unregisterModifier(this);
    }

    abstract public CameraOffsetInfos check(Vector3 position);
    abstract public CameraOffsetInfos checkUnclamped(Vector3 position);

    public struct DistanceResult
    {
        public DistanceResult(float _distance, Vector3 _pos)
        {
            distance = _distance;
            pos = _pos;
        }

        public float distance;
        public Vector3 pos;
    }

    public DistanceResult distance(Vector3 position)
    {
        var onColliderPos = transform.InverseTransformPoint(position);

        var colliderMin = m_collider.center - m_collider.size / 2.0f;
        var colliderMax = m_collider.center + m_collider.size / 2.0f;

        var xP = new Plane(Vector3.right, colliderMax);
        var xN = new Plane(Vector3.left, colliderMin);
        var yP = new Plane(Vector3.up, colliderMax);
        var yN = new Plane(Vector3.down, colliderMin);
        var zP = new Plane(Vector3.forward, colliderMax);
        var zN = new Plane(Vector3.back, colliderMin);

        var xPP = xP.ClosestPointOnPlane(onColliderPos);
        var xNP = xN.ClosestPointOnPlane(onColliderPos);
        var yPP = yP.ClosestPointOnPlane(onColliderPos);
        var yNP = yN.ClosestPointOnPlane(onColliderPos);
        var zPP = zP.ClosestPointOnPlane(onColliderPos);
        var zNP = zN.ClosestPointOnPlane(onColliderPos);

        var xPD = xP.GetDistanceToPoint(onColliderPos);
        var xND = xN.GetDistanceToPoint(onColliderPos);
        var yPD = yP.GetDistanceToPoint(onColliderPos);
        var yND = yN.GetDistanceToPoint(onColliderPos);
        var zPD = zP.GetDistanceToPoint(onColliderPos);
        var zND = zN.GetDistanceToPoint(onColliderPos);
        
        bool sign = true;
        Vector3 target = onColliderPos;

        if (xPD < 0 && xND < 0 && yPD < 0 && yND < 0 && zPD < 0 && zND < 0) //on the collider
        {
            var pTab = new Vector3[]{ xPP, xNP, yPP, yNP, zPP, zNP};
            var dTab = new float[] { xPD, xND, yPD, yND, zPD, zND };

            sign = false;
            float minD = float.MaxValue;
            for (int i = 0; i < dTab.Length; i++)
            {
                if (minD >= Mathf.Abs(dTab[i]))
                {
                    minD = Mathf.Abs(dTab[i]);
                    target = pTab[i];
                }
            }
        }
        else if (xPD >= 0 && yPD >= 0 && zPD >= 0) // corners
            target = new Vector3(colliderMax.x, colliderMax.y, colliderMax.z);
        else if (xPD >= 0 && yPD >= 0 && zND >= 0)
            target = new Vector3(colliderMax.x, colliderMax.y, colliderMin.z);
        else if (xPD >= 0 && yND >= 0 && zPD >= 0)
            target = new Vector3(colliderMax.x, colliderMin.y, colliderMax.z);
        else if (xPD >= 0 && yND >= 0 && zND >= 0)
            target = new Vector3(colliderMax.x, colliderMin.y, colliderMin.z);
        else if (xND >= 0 && yPD >= 0 && zPD >= 0)
            target = new Vector3(colliderMin.x, colliderMax.y, colliderMax.z);
        else if (xND >= 0 && yPD >= 0 && zND >= 0)
            target = new Vector3(colliderMin.x, colliderMax.y, colliderMin.z);
        else if (xND >= 0 && yND >= 0 && zPD >= 0)
            target = new Vector3(colliderMin.x, colliderMin.y, colliderMax.z);
        else if (xND >= 0 && yND >= 0 && zND >= 0)
            target = new Vector3(colliderMin.x, colliderMin.y, colliderMin.z);
        else if (xPD >= 0 && yPD >= 0) //lines
            target = projectPointOnLine(onColliderPos, new Vector3(colliderMax.x, colliderMax.y, colliderMin.z), new Vector3(colliderMax.x, colliderMax.y, colliderMax.z));
        else if (xPD >= 0 && yND >= 0)
            target = projectPointOnLine(onColliderPos, new Vector3(colliderMax.x, colliderMin.y, colliderMin.z), new Vector3(colliderMax.x, colliderMin.y, colliderMax.z));
        else if (xND >= 0 && yPD >= 0)
            target = projectPointOnLine(onColliderPos, new Vector3(colliderMin.x, colliderMax.y, colliderMin.z), new Vector3(colliderMin.x, colliderMax.y, colliderMax.z));
        else if (xND >= 0 && yND >= 0)
            target = projectPointOnLine(onColliderPos, new Vector3(colliderMin.x, colliderMin.y, colliderMin.z), new Vector3(colliderMin.x, colliderMin.y, colliderMax.z));
        else if (xPD >= 0 && zPD >= 0)
            target = projectPointOnLine(onColliderPos, new Vector3(colliderMax.x, colliderMin.y, colliderMax.z), new Vector3(colliderMax.x, colliderMax.y, colliderMax.z));
        else if (xPD >= 0 && zND >= 0)
            target = projectPointOnLine(onColliderPos, new Vector3(colliderMax.x, colliderMin.y, colliderMin.z), new Vector3(colliderMax.x, colliderMax.y, colliderMin.z));
        else if (xND >= 0 && zPD >= 0)
            target = projectPointOnLine(onColliderPos, new Vector3(colliderMin.x, colliderMin.y, colliderMax.z), new Vector3(colliderMin.x, colliderMax.y, colliderMax.z));
        else if (xND >= 0 && zND >= 0)
            target = projectPointOnLine(onColliderPos, new Vector3(colliderMin.x, colliderMin.y, colliderMin.z), new Vector3(colliderMin.x, colliderMax.y, colliderMin.z));
        else if (yPD >= 0 && zPD >= 0)
            target = projectPointOnLine(onColliderPos, new Vector3(colliderMin.x, colliderMax.y, colliderMax.z), new Vector3(colliderMax.x, colliderMax.y, colliderMax.z));
        else if (yPD >= 0 && zND >= 0)
            target = projectPointOnLine(onColliderPos, new Vector3(colliderMin.x, colliderMax.y, colliderMin.z), new Vector3(colliderMax.x, colliderMax.y, colliderMin.z));
        else if (yND >= 0 && zPD >= 0)
            target = projectPointOnLine(onColliderPos, new Vector3(colliderMin.x, colliderMin.y, colliderMax.z), new Vector3(colliderMax.x, colliderMin.y, colliderMax.z));
        else if (yND >= 0 && zND >= 0)
            target = projectPointOnLine(onColliderPos, new Vector3(colliderMin.x, colliderMin.y, colliderMin.z), new Vector3(colliderMax.x, colliderMin.y, colliderMin.z));
        else if (xPD >= 0) // planes
            target = xPP;
        else if (xND >= 0)
            target = xNP;
        else if (yPD >= 0)
            target = yPP;
        else if (yND >= 0)
            target = yNP;
        else if (zPD >= 0)
            target = zPP;
        else if (zND >= 0)
            target = zNP;

        target = transform.TransformPoint(target);

        return new DistanceResult(Vector3.Distance(target, position) * (sign ? 1 : -1), target);
    }

    Vector3 projectPointOnLine(Vector3 p, Vector3 w0, Vector3 w1)
    {
        return Vector3.Project((p - w0), (w1 - w0)) + w0; 
    }
}
