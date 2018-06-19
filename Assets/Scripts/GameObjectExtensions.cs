using System.Reflection;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

public static class GameObjectExtensions
{

    /// <summary>
    /// Returns the full hierarchy name of the game object.
    /// </summary>
    /// <param name="go">The game object.</param>
    public static string GetFullName(this GameObject go)
    {
        string name = go.name;
        while (go.transform.parent != null)
        {

            go = go.transform.parent.gameObject;
            name = go.name + "/" + name;
        }
        return name;
    }

    /// <summary>
    /// Returns the Local Identfier In File of the gameobject
    /// If this gameobject is not saved (just added on the scene without save, or instanciated), this function return 0.
    /// </summary>
    /// <param name="go">The game object.</param>
    /// <returns>The Local Identfier In File.</returns>
    public static int GetLocalID(this GameObject go)
    {
#if UNITY_EDITOR
        PropertyInfo inspectorModeInfo =
    typeof(SerializedObject).GetProperty("inspectorMode", BindingFlags.NonPublic | BindingFlags.Instance);

        SerializedObject serializedObject = new SerializedObject(go);
        inspectorModeInfo.SetValue(serializedObject, InspectorMode.Debug, null);

        SerializedProperty localIdProp =
            serializedObject.FindProperty("m_LocalIdentfierInFile");   //note the misspelling!

        return localIdProp.intValue;
#else
        return 0;
#endif
    }
}