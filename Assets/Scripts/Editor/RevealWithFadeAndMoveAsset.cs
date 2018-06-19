using UnityEngine;
using UnityEditor;

public class RevealWithFadeAndMoveAsset
{
    [MenuItem("Assets/Create/RevealWithFadeAndMove")]
    public static void CreateAsset()
    {
        ScriptableObjectUtility.CreateAsset<RevealWithFadeAndMoveLogic>();
    }
}
