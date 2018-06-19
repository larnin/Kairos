using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public abstract class TriggerBaseLogic : MonoBehaviour
{
    public abstract void onEnter(TriggerInteractionLogic entity);

    public abstract void onExit(TriggerInteractionLogic entity);
}
