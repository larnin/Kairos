using ExpressionParser;
using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class TriggerCameraModifierSmoothBoxLogic : TriggerCameraModifierBaseLogic
{
    [SerializeField] LayerMask m_layerMaskCast;
    
    [SerializeField] bool m_useCustomEffect = false;
    [HideIf("m_useCustomEffect")]
    [SerializeField] EffectType m_effect = EffectType.Linear;
    [ShowIf("m_useCustomEffect")]
    [SerializeField] string m_customEffect = "x";
    
    List<TriggerCameraModifierBaseLogic> m_triggers = new List<TriggerCameraModifierBaseLogic>();
    ExpressionDelegate m_expressionDelegate;

    enum EffectType
    {
        Linear,
        SmoothStart,
        SmootherStart,
        HardStart
    }

    private void Start()
    {
        updateTriggers();

        var parser = new ExpressionParser.ExpressionParser();
        Expression exp = parser.EvaluateExpression(m_useCustomEffect ? m_customEffect : expressionFromEffectType(m_effect));
        string[] parameters = new string[] { "x" };
        m_expressionDelegate = exp.ToDelegate(parameters);
    }

    string expressionFromEffectType(EffectType effect)
    {
        switch(effect)
        {
            case EffectType.HardStart:
                return "log(x+1)";
            case EffectType.SmoothStart:
                return "x*x";
            case EffectType.SmootherStart:
                return "(e^x)-1";
            case EffectType.Linear:
            default:
                return "x";
        }
    }

    public override CameraOffsetInfos check(Vector3 position)
    {
        List<DistanceResult> results = new List<DistanceResult>();
        foreach (var t in m_triggers)
        {
            results.Add(t.distance(position));
            if(results[results.Count-1].distance <= 0)
                return new CameraOffsetInfos();
        }

        List<float> values = new List<float>(results.Count);
        float sum = 0;
        for(int i = 0; i < results.Count; i++)
        { 
            float v = 1;
            for (int j = 0; j < results.Count; j++)
                if (i != j)
                    v *= results[j].distance;
            v = (float)m_expressionDelegate(v);
            values.Add(v);
            sum += v;
        }

        CameraOffsetInfos infos = new CameraOffsetInfos();
        for(int i = 0; i < m_triggers.Count; i++)
            infos += m_triggers[i].checkUnclamped(results[i].pos) * (values[i] / sum);

        return infos;
    }

    public override CameraOffsetInfos checkUnclamped(Vector3 position)
    {
        Debug.LogError("Unsupported function !");
        return new CameraOffsetInfos();
    }

    public void updateTriggers()
    {
        m_triggers.Clear();
        var colliders = Physics.OverlapBox(transform.position, Vector3.Scale(m_collider.size, transform.lossyScale) / 2f, transform.rotation, m_layerMaskCast);
        foreach(var c in colliders)
        {
            if (c.gameObject == gameObject)
                continue;
            var comps = c.GetComponents<TriggerCameraModifierBaseLogic>();
            foreach(var comp in comps)
                if(!(comp is TriggerCameraModifierSmoothBoxLogic))
                    m_triggers.Add(comp);
        }
    }

    
}
