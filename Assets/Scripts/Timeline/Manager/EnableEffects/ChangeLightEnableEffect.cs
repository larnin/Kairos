using UnityEngine;
using DG.Tweening;
using Sirenix.OdinInspector;

public class ChangeLightEnableEffect : MonoBehaviour
{
    [SerializeField] Light m_lightToChange = null;

    [SerializeField] float newRange;
    [SerializeField] float newSpotAngle;
    [SerializeField] Color newColor;
    [SerializeField] float newIntensity;
    [SerializeField, HorizontalGroup(Width = 20), HideLabel, LabelWidth(1)] bool m_lerp = false;
    [SerializeField, HorizontalGroup, EnableIf("m_lerp"), LabelWidth(50)] float m_time = 1;
    [SerializeField, HorizontalGroup, EnableIf("m_lerp"), LabelWidth(50)] Ease m_ease = Ease.Linear;

    float oldRange;
    float oldSpotAngle;
    Color oldColor;
    float oldIntensity;
   

    void OnEnable()
    {
        oldRange = m_lightToChange.range;
        oldSpotAngle = m_lightToChange.spotAngle;
        oldColor = m_lightToChange.color;
        oldIntensity = m_lightToChange.intensity;

        if (m_lerp)
            ease(newRange, newSpotAngle, newColor, newIntensity);
        else instantChanges(newRange, newSpotAngle, newColor, newIntensity);
    } 

    void OnDisable()
    {
        if (m_lerp)
            ease(oldRange, oldSpotAngle, oldColor, oldIntensity);
        else instantChanges(oldRange, oldSpotAngle, oldColor, oldIntensity);
    }

    void ease(float range, float angle, Color color, float intensity)
    {
		if (m_lightToChange != null)
		{
			DOVirtual.Float(m_lightToChange.range, range, m_time, x => m_lightToChange.range = x).SetEase(m_ease);
			DOVirtual.Float(m_lightToChange.spotAngle, angle, m_time, x => m_lightToChange.spotAngle = x).SetEase(m_ease);
			m_lightToChange.DOColor(color, m_time).SetEase(m_ease);
			m_lightToChange.DOIntensity(intensity, m_time).SetEase(m_ease);
		}
    }

    void instantChanges(float range, float angle, Color color, float intensity)
    {
        m_lightToChange.range = range;
        m_lightToChange.spotAngle = angle;
        m_lightToChange.color = color;
        m_lightToChange.intensity = intensity;
    }
}