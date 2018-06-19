using UnityEngine;
using System.Collections;
using Cinemachine;
using System.Collections.Generic;
using System;

public class CameraMixerLogic : MonoBehaviour
{
    [SerializeField] bool m_drawDebug = false;
    [SerializeField] Transform m_target;

    CinemachineMixingCamera m_cinemachineMixer;
    Transform m_baseCamerasParent;
    VirtualCameraInfosLogic[] m_cameras;

    int m_currentTriangleIndex = -1;
    int m_outCameraIndex = -1;

    List<Triangle> m_triangles = new List<Triangle>();
    List<OutCameraInfos> m_outCameras = new List<OutCameraInfos>();

    List<VirtualCameraInfosLogic> m_camerasOnMixer = new List<VirtualCameraInfosLogic>();

    struct OutCameraInfos
    {
        public VirtualCameraInfosLogic pos1;
        public VirtualCameraInfosLogic pos2;
    }
    
    struct Triangle
    {
        public VirtualCameraInfosLogic pos1;
        public VirtualCameraInfosLogic pos2;
        public VirtualCameraInfosLogic pos3;
    }

    private void Start()
    {
        m_cinemachineMixer = transform.Find("MixingCamera").GetComponent<CinemachineMixingCamera>();

        m_baseCamerasParent = transform.Find("Cameras");
        m_cameras = m_baseCamerasParent.GetComponentsInChildren<VirtualCameraInfosLogic>();
        m_cinemachineMixer.Priority ++;

        createTriangles();

        updateCurrentTriangle();
    }

    private void Update()
    {
        if (m_drawDebug)
            drawDebug();

        if(m_currentTriangleIndex < 0 || ! isTargetOnTriangle(m_triangles[m_currentTriangleIndex]))
            updateCurrentTriangle();
        if (m_currentTriangleIndex < 0)
            execOutside();
        else execCurrentTriangle();
    }

    void drawDebug()
    {
        Color c = Color.green;
        float height = m_target.position.y + 0.1f;

        foreach(var t in m_triangles)
        {
            Vector3 pos1 = t.pos1.target; pos1.y = height;
            Vector3 pos2 = t.pos2.target; pos2.y = height;
            Vector3 pos3 = t.pos3.target; pos3.y = height;

            Debug.DrawLine(pos1, pos2, c);
            Debug.DrawLine(pos2, pos3, c);
            Debug.DrawLine(pos3, pos1, c);
        }

        foreach(var cam in m_outCameras)
        {
            Vector3 pos1 = cam.pos1.target; pos1.y = height + 0.1f;
            Vector3 pos2 = cam.pos2.target; pos2.y = height + 0.1f;

            Debug.DrawLine(pos1, pos2, c);
        }

        if(m_currentTriangleIndex >= 0)
        {
            Triangle t = m_triangles[m_currentTriangleIndex];

            Vector3 pos1 = t.pos1.target; 
            Vector3 pos2 = t.pos2.target;
            Vector3 pos3 = t.pos3.target;

            Debug.DrawLine(pos1, pos2, Color.red);
            Debug.DrawLine(pos2, pos3, Color.red);
            Debug.DrawLine(pos3, pos1, Color.red);

            pos1.y = height;
            pos2.y = height;
            pos3.y = height;

            Debug.DrawRay(pos1, Vector3.up * 10, Color.red);
            Debug.DrawRay(pos2, Vector3.up * 10, Color.red);
            Debug.DrawRay(pos3, Vector3.up * 10, Color.red);
        }
        else if(m_outCameraIndex >= 0)
        {
            OutCameraInfos cam = m_outCameras[m_outCameraIndex];

            Vector3 pos1 = cam.pos1.target;
            Vector3 pos2 = cam.pos2.target;

            Debug.DrawLine(pos1, pos2, Color.red);

            pos1.y = height;
            pos2.y = height;

            Debug.DrawRay(pos1, Vector3.up * 10, Color.red);
            Debug.DrawRay(pos2, Vector3.up * 10, Color.red);
        }
    }

    bool isTargetOnTriangle(Triangle t)
    {
        Vector2 target = toVect2(m_target.transform.position);

        Vector2 pos1 = toVect2(t.pos1.target);
        Vector2 pos2 = toVect2(t.pos2.target);
        Vector2 pos3 = toVect2(t.pos3.target);

        bool b1, b2, b3;

        b1 = sign(target, pos1, pos2) < 0.0f;
        b2 = sign(target, pos2, pos3) < 0.0f;
        b3 = sign(target, pos3, pos1) < 0.0f;

        return ((b1 == b2) && (b2 == b3));
    }

    float sign(Vector2 p1, Vector2 p2, Vector2 p3)
    {
        return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
    }

    Vector2 toVect2(Vector3 v)
    {
        return new Vector2(v.x, v.z);
    }

    void createTriangles()
    {
        m_triangles.Clear();
        m_outCameras.Clear();

        if(m_cameras.Length < 3)
        {
            Debug.LogError("You need at least 3 cinemachine virtual camera !");
            return;
        }

        for(int i = 0; i < m_cameras.Length; i++)
            for(int j = i + 1; j < m_cameras.Length; j++)
                for(int k = j + 1; k < m_cameras.Length; k++)
                {
                    bool isOk = true;

                    var p1 = toVect2(m_cameras[i].target);
                    var p2 = toVect2(m_cameras[j].target);
                    var p3 = toVect2(m_cameras[k].target);

                    var circumcenterPos = circumcenter(p1, p2, p3);
                    var sqrRadius = (circumcenterPos - p1).sqrMagnitude;
                    
                    for (int l = 0; l < m_cameras.Length; l++)
                    {
                        if (l == i || l == j || l == k)
                            continue;

                        var p4 = toVect2(m_cameras[l].target);
                        if ((circumcenterPos - p4).sqrMagnitude <= sqrRadius)
                        {
                            isOk = false;
                            break;
                        }
                    }
                    if(isOk)
                    {
                        Triangle t = new Triangle();
                        t.pos1 = m_cameras[i];
                        t.pos2 = m_cameras[j];
                        t.pos3 = m_cameras[k];
                        m_triangles.Add(t);
                    }
                }

        for(int i = 0; i < m_cameras.Length; i++)
            for(int j = i + 1; j < m_cameras.Length; j++)
            {
                var p1 = toVect2(m_cameras[i].target);
                var p2 = toVect2(m_cameras[j].target);

                bool isOk = true;
                int side = 0;
                for(int k = 0; k < m_cameras.Length; k++)
                {
                    if (k == i || k == j)
                        continue;

                    var s = isLeft(p1, p2, toVect2(m_cameras[k].target)) ? 1 : -1;
                    if (side == 0)
                        side = s;
                    else if(side != s)
                    {
                        isOk = false;
                        break;
                    }
                }

                if(isOk)
                {
                    OutCameraInfos c = new OutCameraInfos();
                    c.pos1 = m_cameras[i];
                    c.pos2 = m_cameras[j];
                    m_outCameras.Add(c);
                }
            }
    }

    Vector2 circumcenter(Vector2 a, Vector2 b, Vector2 c)
    {
        Vector3 aa = new Vector3(a.x, 0, a.y);
        Vector3 bb = new Vector3(b.x, 0, b.y);
        Vector3 cc = new Vector3(c.x, 0, c.y);

        var ac = cc - aa;
        var ab = bb - aa;
        var abXac = Vector3.Cross(ab, ac);
        float sqrabXax = 2 * abXac.sqrMagnitude;

        var toCircumcenter = (Vector3.Cross(abXac, ab) * ac.sqrMagnitude + Vector3.Cross(ac, abXac) * ab.sqrMagnitude) / sqrabXax;

        return a + toVect2(toCircumcenter);
    }

    void updateCurrentTriangle()
    {
        m_currentTriangleIndex = -1;
        for(int i = 0; i < m_triangles.Count; i++)
        {
            if(isTargetOnTriangle(m_triangles[i]))
            {
                m_currentTriangleIndex = i;
                m_outCameraIndex = -1;
                changeMixerCameras(new List<VirtualCameraInfosLogic> { m_triangles[i].pos1, m_triangles[i].pos2, m_triangles[i].pos3 });
                return;
            }
        }
    }

    void execCurrentTriangle()
    {
        Triangle t = m_triangles[m_currentTriangleIndex];

        var pos1 = toVect2(t.pos1.target);
        var pos2 = toVect2(t.pos2.target);
        var pos3 = toVect2(t.pos3.target);
        var target = toVect2(m_target.position);

        var p1 = intersectLines(pos1, target, pos2, pos3);
        var p2 = intersectLines(pos2, target, pos1, pos3);
        var p3 = intersectLines(pos3, target, pos1, pos2);

        m_cinemachineMixer.m_Weight0 = t.pos1.easeValue((p1 - target).magnitude / (pos1 - p1).magnitude);
        m_cinemachineMixer.m_Weight1 = t.pos2.easeValue((p2 - target).magnitude / (pos2 - p2).magnitude);
        m_cinemachineMixer.m_Weight2 = t.pos3.easeValue((p3 - target).magnitude / (pos3 - p3).magnitude);
    }

    void execOutside()
    {
        updateCurrentOutCameras();

        OutCameraInfos cam = m_outCameras[m_outCameraIndex];

        var pos1 = toVect2(cam.pos1.target);
        var pos2 = toVect2(cam.pos2.target);
        var target = toVect2(m_target.position);

        var p = projectPointOnLine(pos1, pos2, target);
        if (Vector2.Dot(pos1 - pos2, pos1 - p) < 0)
            p = pos1;
        else if (Vector2.Dot(pos2 - pos1, pos2 - p) < 0)
            p = pos2;

        m_cinemachineMixer.m_Weight0 = cam.pos1.easeValue((pos2 - p).magnitude / (pos1 - pos2).magnitude);
        m_cinemachineMixer.m_Weight1 = cam.pos2.easeValue((pos1 - p).magnitude / (pos2 - pos1).magnitude);
    }

    void updateCurrentOutCameras()
    {
        float bestDistance = float.MaxValue;
        int bestindex = -1;

        var target = toVect2(m_target.position);

        for(int i = 0; i < m_outCameras.Count; i++)
        {
            var p1 = toVect2(m_outCameras[i].pos1.target);
            var p2 = toVect2(m_outCameras[i].pos2.target);

            var d = distancePointSegment(p1, p2, target);
            if(d < bestDistance)
            {
                bestDistance = d;
                bestindex = i;
            }
        }
        if (m_outCameraIndex != bestindex)
            changeMixerCameras(new List<VirtualCameraInfosLogic> {m_outCameras[bestindex].pos1, m_outCameras[bestindex].pos2});
        m_outCameraIndex = bestindex;
    }

    Vector2 ortho(Vector2 v)
    {
        return new Vector2(v.y, -v.x);
    }
     
    bool isLeft(Vector2 p1, Vector2 p2, Vector2 p)
    {
        return Vector2.Dot(p2 - p1, ortho(p - p2)) > 0;
    }

    float distancePointSegment(Vector2 w0, Vector2 w1, Vector2 p)
    {
        var pSeg = projectPointOnLine(w0, w1, p);

        if (Vector2.Dot(w0 - w1, w0 - p) < 0)
            pSeg = w0;
        else if (Vector2.Dot(w1 - w0, w1 - p) < 0)
            pSeg = w1;

        return (p - pSeg).magnitude;
    }

    Vector2 projectPointOnLine(Vector2 w1, Vector2 w2, Vector2 p)
    {
        var m = (w2.y - w1.y) / (w2.x - w1.x);
        var b = w1.y - (m * w1.x);

        return new Vector2((m * p.y + p.x - m * b) / (m * m + 1), (m * m * p.y + m * p.x + b) / (m * m + 1));
    }

    Vector2 intersectLines(Vector2 a1, Vector2 a2, Vector2 b1, Vector2 b2)
    {
        var sPos = a2 - a1;
        var sSeg = b2 - b1;
        var  denom = sPos.x* sSeg.y -sPos.y * sSeg.x;

        var u = (a1.x * sSeg.y - b1.x * sSeg.y - sSeg.x * a1.y + sSeg.x * b1.y) / denom;

        return a1 - sPos * u;
    }

    void changeMixerCameras(List<VirtualCameraInfosLogic> cameras)
    {
        var mixerTransform = m_cinemachineMixer.transform;
        
        foreach (var cam in m_camerasOnMixer)
            cam.virtualCamera.transform.parent = cam.transform;

        m_camerasOnMixer.Clear();

        foreach(var cam in cameras)
        {
            cam.virtualCamera.transform.parent = mixerTransform;
            m_camerasOnMixer.Add(cam);
        }
    }
}
