using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using DG.Tweening;
using UnityEngine;

[Serializable]
public class PlaceholderMaskEffect : MaskEffectBase
{
    [SerializeField] Color m_startColor;
    [SerializeField] Color m_endColor;
    [SerializeField] float m_effectDuration;
    [SerializeField] Ease m_easeEffect = Ease.Linear;

    public override void exec(MaskLogic mask)
    {
        var renderer = mask.GetComponentInChildren<Renderer>();
        if (renderer != null)
        {
            var material = renderer.material;
            material.color = m_startColor;
            material.DOColor(m_endColor, m_effectDuration).SetEase(m_easeEffect).OnComplete(() => onEndEffect());
        }
        else onEndEffect();
    }
}
