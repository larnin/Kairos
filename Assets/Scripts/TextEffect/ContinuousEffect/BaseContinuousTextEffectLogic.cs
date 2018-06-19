using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public abstract class BaseContinuousTextEffectLogic 
{
    [NonSerialized] public List<DG.Tweening.Tween> m_tweens;
    public abstract void apply(Letter letter);
    public virtual void globalInit(MonoBehaviour mono){}
    public virtual void globalReset(MonoBehaviour mono){}
}
