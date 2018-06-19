using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Cinemachine;
using UnityEngine;

class CameraDioramaAction : BaseDioramaAction
{
    const int hightWeight = 100;
    const int lowWeight = 0;

    [SerializeField] CinemachineVirtualCamera m_camera;

    public override void triggerBegin()
    {
        m_camera.m_Priority = hightWeight;
    }

    public override void triggerEnd()
    {
        m_camera.m_Priority = lowWeight;
    }
}
