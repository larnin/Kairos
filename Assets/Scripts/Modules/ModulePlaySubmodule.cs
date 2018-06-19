using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ModulePlaySubmodule : ModuleBase
{
    [SerializeField] ModuleLogic m_module;

    public override bool update()
    {
        if(m_module == null)
        {
            Debug.LogError("The submodule is null !");
            return true;
        }
        return m_module.module.update();
    }
}