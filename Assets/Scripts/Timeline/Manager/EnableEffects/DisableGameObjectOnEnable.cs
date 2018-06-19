using UnityEngine;
using DG.Tweening;
using Sirenix.OdinInspector;

public class DisableGameObjectOnEnable : MonoBehaviour
{
    [SerializeField] GameObject[] gameObjectToDisable;

    void OnEnable()
    {
        foreach(GameObject e in gameObjectToDisable)
        {
            if(e)
                e.SetActive(false);
        }
    }  
    
    void OnDisable()
    {
        foreach (GameObject e in gameObjectToDisable)
        {
            if(e)
                e.SetActive(true);
        }
    }
}
    
