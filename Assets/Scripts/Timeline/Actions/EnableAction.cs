using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class EnableAction : BaseAction
{
    public bool m_enabled;

    public override void trigger(GameObject obj)
    {
        obj.SetActive(m_enabled);
    }
}