using UnityEngine;
using UnityEditor;

public class ChoicesAndBalanceEditor
{
    [MenuItem("Assets/Create/CorrespondingChoiceAndBalance")]
    public static void CreateAsset()
    {
        ScriptableObjectUtility.CreateAsset<CorrespondingChoiceAndBalance>();
    }
}
