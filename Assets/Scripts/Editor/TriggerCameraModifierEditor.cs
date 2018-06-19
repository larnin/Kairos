using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(TriggerCameraModifierBaseLogic))]
public class TriggerCameraModifierEditor : Editor
{
    public Color m_color = Color.blue;

    private void OnSceneGUI()
    {
        TriggerCameraModifierBaseLogic triggerCameraModifier = target as TriggerCameraModifierBaseLogic;
        var collider = triggerCameraModifier.GetComponent<BoxCollider>();
        if (collider == null)
            return;

        var transform = triggerCameraModifier.transform;
        var min = collider.center - collider.size / 2.0f;
        var max = collider.center + collider.size / 2.0f;
        Handles.color = m_color;
        Handles.DrawLine(transform.TransformPoint(new Vector3(min.x, min.y, min.z)), transform.TransformPoint(new Vector3(max.x, min.y, min.z)));
        Handles.DrawLine(transform.TransformPoint(new Vector3(min.x, min.y, min.z)), transform.TransformPoint(new Vector3(min.x, max.y, min.z)));
        Handles.DrawLine(transform.TransformPoint(new Vector3(min.x, max.y, min.z)), transform.TransformPoint(new Vector3(max.x, max.y, min.z)));
        Handles.DrawLine(transform.TransformPoint(new Vector3(max.x, min.y, min.z)), transform.TransformPoint(new Vector3(max.x, max.y, min.z)));

        Handles.DrawLine(transform.TransformPoint(new Vector3(min.x, min.y, max.z)), transform.TransformPoint(new Vector3(max.x, min.y, max.z)));
        Handles.DrawLine(transform.TransformPoint(new Vector3(min.x, min.y, max.z)), transform.TransformPoint(new Vector3(min.x, max.y, max.z)));
        Handles.DrawLine(transform.TransformPoint(new Vector3(min.x, max.y, max.z)), transform.TransformPoint(new Vector3(max.x, max.y, max.z)));
        Handles.DrawLine(transform.TransformPoint(new Vector3(max.x, min.y, max.z)), transform.TransformPoint(new Vector3(max.x, max.y, max.z)));

        Handles.DrawLine(transform.TransformPoint(new Vector3(min.x, min.y, min.z)), transform.TransformPoint(new Vector3(min.x, min.y, max.z)));
        Handles.DrawLine(transform.TransformPoint(new Vector3(max.x, min.y, min.z)), transform.TransformPoint(new Vector3(max.x, min.y, max.z)));
        Handles.DrawLine(transform.TransformPoint(new Vector3(max.x, max.y, min.z)), transform.TransformPoint(new Vector3(max.x, max.y, max.z)));
        Handles.DrawLine(transform.TransformPoint(new Vector3(min.x, max.y, min.z)), transform.TransformPoint(new Vector3(min.x, max.y, max.z)));
    }
}