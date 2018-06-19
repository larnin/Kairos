using UnityEngine;
using UnityEditor;
 
public class InformationForChoiceUIEditor
{
    [MenuItem("Assets/Create/InformationForChoiceUI")]
    public static void CreateAsset()
    {
        ScriptableObjectUtility.CreateAsset<InformationForChoiceUI>();
    }
}
