using UnityEngine;
using System.Collections;
using DG.Tweening;

public class ChangeLightScateringEnableEffect : MonoBehaviour
{
    [SerializeField] VolumetricLight m_volumetricLight;
    [SerializeField] float m_value;
    [SerializeField] float m_duration;
    [SerializeField] Ease m_ease = Ease.Linear;
    float m_oldValue;

    private void OnEnable()
    {
        m_oldValue = m_volumetricLight.ScatteringCoef;
        DOVirtual.Float(m_oldValue, m_value, m_duration, x => m_volumetricLight.ScatteringCoef = x).SetEase(m_ease);
    }

    private void OnDisable()
    {

        DOVirtual.Float(m_value, m_oldValue, m_duration, x => m_volumetricLight.ScatteringCoef = x).SetEase(m_ease);
    }
}
