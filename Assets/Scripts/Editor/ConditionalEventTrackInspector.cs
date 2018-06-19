using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(ConditionalEventTrack)), CanEditMultipleObjects]
public class ConditionalEventTrackInspector : Editor 
{

    public override void OnInspectorGUI()
    {
        serializedObject.Update();
        
        EditorGUILayout.PropertyField(serializedObject.FindProperty("m_condition"), true);
        serializedObject.ApplyModifiedProperties();
    }
}