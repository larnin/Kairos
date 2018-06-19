using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using DG.Tweening;

public class ShadowLerpMoveLogic : MonoBehaviour
{
    const string propertyName = "_Apparition";

    [SerializeField] Ease m_ease = Ease.Linear;
    [SerializeField] ParticleSystem m_particles;
    [SerializeField] Renderer m_renderer;

    bool m_onEase = false;
    Vector3 m_targetPos;
    Quaternion m_targetRotation;

    public Vector3 getTargetPosition()
    {
        if (m_onEase)
            return m_targetPos;
        return transform.position;
    }

    public Quaternion getTargetRotation()
    {
        if (m_onEase)
            return m_targetRotation;
        return transform.rotation;
    }

    public void moveTo(Vector3 pos, Quaternion rot, float duration, float fadeDuration)
    {
        m_onEase = true;
        m_targetPos = pos;
        m_targetRotation = rot;
        transform.DOMove(pos, duration).SetEase(m_ease);
        transform.DORotateQuaternion(rot, duration).SetEase(m_ease);
        if(m_particles != null)
            m_particles.Play();
        DOVirtual.DelayedCall(duration, () =>
        {
            if (m_particles != null)
                m_particles.Stop(false, ParticleSystemStopBehavior.StopEmitting);
            m_onEase = false;
        });

        var mat = m_renderer.material;
        mat.DOFloat(0, propertyName, fadeDuration).OnComplete(
            () => DOVirtual.DelayedCall(duration - 2 * fadeDuration,
            () => mat.DOFloat(1, propertyName, fadeDuration)));
    }
}
