using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public abstract class BaseAction
{
    public abstract void trigger(GameObject obj);
    public virtual void triggerEnd(GameObject obj) { }
}
