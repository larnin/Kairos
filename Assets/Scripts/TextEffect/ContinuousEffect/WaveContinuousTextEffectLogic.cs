using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

[Serializable]
public class WaveContinuousTextEffectLogic : BaseContinuousTextEffectLogic
{
    public float m_speed = 1f;
    public float m_strenght = 0.1f;
    public float m_CosParam = 1f;

    float cosNumberAnimated = 0f;

  //  Coroutine coroutine;

    public override void apply(Letter letter)
    {
        letter.position = Vector3.zero;

        m_tweens.Add(DOTween.To(
        () => letter.position,
        (x) =>
        {
            letter.position = x;
            Vector3 vec = (float)(Math.Cos((cosNumberAnimated + letter.index) * m_CosParam) * m_strenght )* Vector3.up;

            letter.VV[0 + letter.vertexIndex] = vec + letter.initialVV[0];
            letter.VV[1 + letter.vertexIndex] = vec + letter.initialVV[1];
            letter.VV[2 + letter.vertexIndex] = vec + letter.initialVV[2];
            letter.VV[3 + letter.vertexIndex] = vec + letter.initialVV[3];
        }, Vector3.up, 1f).SetLoops(-1));
    }

    public override void globalInit(MonoBehaviour mono)
    {
        mono.StartCoroutine(movecos());
    }
    public override void globalReset(MonoBehaviour mono)
    {
        mono.StopCoroutine(movecos());
    }

    IEnumerator movecos()
    {
        while(true)
        {
            cosNumberAnimated += Time.deltaTime * m_speed;
            yield return null;
        }
    }
}
