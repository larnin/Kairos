using Cinemachine;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using DG.Tweening;
using Sirenix.OdinInspector;

public class VirtualCameraInfosLogic : MonoBehaviour
{
    [HideLabel][HorizontalGroup("ease", Width = 20)]
    [SerializeField] bool m_useCurve = false;
    [HideIf("m_useCurve")][HorizontalGroup("ease")]
    [SerializeField] Ease m_ease = Ease.Linear;
    [ShowIf("m_useCurve")][HorizontalGroup("ease")]
    [SerializeField] AnimationCurve m_curve;

    Transform m_target;
    CinemachineVirtualCamera m_camera;
    Vector3 m_targetPos;

    private void Awake()
    {
        m_target = transform;
        m_camera = transform.Find("Camera").GetComponent<CinemachineVirtualCamera>();
        m_camera.Priority = 0;

        m_targetPos = m_target.position;
    }

    public Vector3 target
    {
        get
        {
            return m_targetPos;
        }
    }

    public GameObject targetObj
    {
        get
        {
            if (m_target != null)
                return m_target.gameObject;
            return gameObject;
        }
    }

    public float easeValue(float value)
    {
        if (m_useCurve)
            return DOVirtual.EasedValue(0, 1, value, m_curve);
        else return DOVirtual.EasedValue(0, 1, value, m_ease);
    }

    public CinemachineVirtualCamera virtualCamera { get { return m_camera; } }
}
