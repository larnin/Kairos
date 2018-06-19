using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

[Serializable]
public abstract class BaseCheatEffect
{
    public string key;

    /// <summary>
    /// This function allows the cheat to draw things on the GUI
    /// </summary>
    public abstract void onGui();

    /// <summary>
    /// Update the cheat
    /// This function start to be called when the cheat is enable with a key
    /// </summary>
    /// <returns>
    /// When this function return false, this function stop to be called every frame
    /// </returns>
    public abstract bool onUpdate();
}