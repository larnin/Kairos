using UnityEngine;
using DG.Tweening;
using Sirenix.OdinInspector;

public class SnapToFolletEnableEffect : MonoBehaviour
{

    void OnEnable()
    {
        GameObject follet = GameObject.FindGameObjectWithTag("Player");
        transform.position = follet.transform.position;
    }
}
    
