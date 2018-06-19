using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ModuleList : ModuleBase
{
    [SerializeField] List<ModuleBase> m_modules = new List<ModuleBase>();

    int m_moduleIndex = 0;

    public override bool update()
    {
        if(m_modules == null)
        {
            Debug.LogError("Module list null !");
            return true;
        }

        if (m_moduleIndex >= m_modules.Count)
            return true;
        if(m_modules[m_moduleIndex] == null)
        {
            Debug.LogError("Module null at the index " + m_moduleIndex + " !");
            m_moduleIndex++;
        }
        else if (m_modules[m_moduleIndex].update())
            m_moduleIndex++;
        if (m_moduleIndex >= m_modules.Count)
        {
            m_moduleIndex = 0;
            return true;
        }
        return false;
    }
}
