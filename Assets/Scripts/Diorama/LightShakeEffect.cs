using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using DG.Tweening;
using TMPro;

class LightShakeEffect : MonoBehaviour
{
    [SerializeField] float m_strength = 0.075f;
    [SerializeField] float m_speed = 0.1f;
    [SerializeField] float m_delay = 0.1f;
    [SerializeField] bool m_useZ = false;

    Tween shakingEffect = null;

    void OnEnable()
    {
        shakingEffect = transform.DOShakePosition(999f, new Vector3(m_strength, m_strength, m_useZ ? m_strength : 0f ), 10, 90, false, false).SetLoops(-1);
        shakingEffect.timeScale = m_speed;
        shakingEffect.SetDelay(m_delay);
    }

    void OnDisable()
    {
        if(shakingEffect != null)
            shakingEffect.Kill(true);
    }


}

