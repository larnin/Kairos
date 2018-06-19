using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestroyParticleWhenDone : MonoBehaviour
{
    float m_lifetime = 5f;

    private void Start()
    {
        Destroy(gameObject, m_lifetime);
    }
    
}
