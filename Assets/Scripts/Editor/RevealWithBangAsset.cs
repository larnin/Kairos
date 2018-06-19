using UnityEngine;
using UnityEditor;

public class RevealWithBangAsset
{
    [MenuItem("Assets/Create/RevealWithBang")]
    public static void CreateAsset()
    {
        ScriptableObjectUtility.CreateAsset<RevealWithBangLogic>();
    }
}
