using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

class ClearSaveEditor
{
    [MenuItem("Tools/Clear save")]
    public static void ClearSave()
    {
        SaveSystem.instance().reset();
        Debug.Log("Save clear !");
    }
}
