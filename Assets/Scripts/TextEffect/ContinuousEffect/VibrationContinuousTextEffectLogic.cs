using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

[Serializable]
public class VibrationContinuousTextEffectLogic : BaseContinuousTextEffectLogic
{
    public float m_strengh = 0.01f;
    public float m_speedScale = 0.75f;
    public float m_timeForWave = 9999f;

    public override void apply(Letter letter)
    {
        letter.position = Vector3.zero;

        Tween P = null;
        P = DOTween.Shake(
        () => letter.position,
        (x) =>
        {
            letter.position = x;

            letter.VV[0 + letter.vertexIndex] = x + letter.initialVV[0];
            letter.VV[1 + letter.vertexIndex] = x + letter.initialVV[1];
            letter.VV[2 + letter.vertexIndex] = x + letter.initialVV[2];
            letter.VV[3 + letter.vertexIndex] = x + letter.initialVV[3];
        }, m_timeForWave, m_strengh);
        m_tweens.Add(P);
        m_tweens[m_tweens.Count - 1].SetLoops(-1);
        m_tweens[m_tweens.Count - 1].timeScale = m_speedScale;
    }
}
