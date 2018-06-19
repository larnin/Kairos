using UnityEngine;
using UnityEditor;

public class RevealWithClapWaveAsset
{
    [MenuItem("Assets/Create/RevealWithClapWave")]
    public static void CreateAsset()
    {
        ScriptableObjectUtility.CreateAsset<RevealWithClapWaveLogic>();
    }
}
