using UnityEngine;
using System.Collections;
using Sirenix.OdinInspector;

public class FollowTargetCamera : BaseUpdatableLogic
{
    [SerializeField] Transform m_target = null;
    
    Vector3 m_offset;
    CameraLogic m_camera;

    public Transform target { get { return m_target; } }
    

    private void Start()
    {
        m_offset = transform.position - m_target.transform.position;
        m_camera = GetComponentInChildren<CameraLogic>();
    }

    protected override void onUpdate()
    {
        transform.position = m_target.transform.position + m_offset;

        m_camera.onUpdate();
    }
}
