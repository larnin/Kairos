using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ModuleDelay : ModuleBase
{
    [SerializeField] float m_delay;

    float m_currentTime = 0;

    public override bool update()
    {
        m_currentTime += Time.deltaTime;
        if (m_currentTime >= m_delay)
        {
            m_currentTime = 0;
            return true;
        }
        return false;
    }
}