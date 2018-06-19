using UnityEngine;
using UnityEditor;

public class RevealWithSmokeAsset
{
    [MenuItem("Assets/Create/RevealWithSmokeLogic")]
    public static void CreateAsset()
    {
        ScriptableObjectUtility.CreateAsset<RevealWithSmokeLogic>();
    }
}
