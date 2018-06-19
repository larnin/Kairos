using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;

public class BalanceOfCoherenceLogic : MonoBehaviour
{
    class ParticleSystemInfos
    {
        public ParticleSystemInfos(ParticleSystem p)
        {
            mainModule = p.main;
            emissionModule = p.emission;
            m_baseStartLifeTime = p.main.startLifetime;
            m_baseRate = p.emission.rateOverTime;
        }
        
        ParticleSystem.MainModule mainModule;
        ParticleSystem.EmissionModule emissionModule;
        ParticleSystem.MinMaxCurve m_baseStartLifeTime;
        ParticleSystem.MinMaxCurve m_baseRate;

        public void set(float value)
        {
            mainModule.startLifetime = lerp(m_baseStartLifeTime, value);
            emissionModule.rateOverTime = lerp(m_baseRate, value);
        }

        ParticleSystem.MinMaxCurve lerp(ParticleSystem.MinMaxCurve p, float value)
        {
            switch(p.mode)
            {
                case ParticleSystemCurveMode.Constant:
                    p.constant *= value;
                    break;
                case ParticleSystemCurveMode.Curve:
                case ParticleSystemCurveMode.TwoCurves:
                    p.curveMultiplier *= value;
                    break;
                case ParticleSystemCurveMode.TwoConstants:
                    p.constantMin *= value;
                    p.constantMax *= value;
                    break;
                default:
                    break;
            }
            return p;
        }
    }

    [SerializeField] float m_minValue = -100; 
	public float balanceMinValue { get { return m_minValue; } }
    [SerializeField] float m_maxValue = 100;
    [SerializeField] float m_rightActionValue = 20;
    [SerializeField] float m_wrongActionValue = -20;
    [SerializeField] bool m_showValueOnGui = true;

    [SerializeField] GameObject m_goodEffects;
    [SerializeField] GameObject m_badEffects;
    [SerializeField] Material[] m_judeMats;

    [SerializeField] float m_lerpTime = 1;
    [SerializeField] Ease m_lerpShape = Ease.Linear;

    List<ParticleSystemInfos> m_goodParticles = new List<ParticleSystemInfos>();
    List<ParticleSystemInfos> m_badParticles = new List<ParticleSystemInfos>();

    float m_value = 0;
	public float balanceValue { get { return m_value; } }
    SubscriberList m_subscriberList = new SubscriberList();

    private void Awake()
    {
        m_value = SaveSystem.instance().getFloat("BalanceOfCoherence");

        m_subscriberList.Add(new Event<AddBalanceOfCoherenceValueEvent>.Subscriber(onEndObjectSelection));
        m_subscriberList.Add(new Event<SetBalanceOfCoherenceValueEvent>.Subscriber(onSetBalanceOfCoherenceValue));
        m_subscriberList.Subscribe();
    }

    private void Start()
    {
        findParticleSystems();
        onUpdatingValue();
    }

    void findParticleSystems()
    {
        m_goodParticles.Clear();
        m_badParticles.Clear();

        foreach (var p in m_goodEffects.GetComponentsInChildren<ParticleSystem>())
            m_goodParticles.Add(new ParticleSystemInfos(p));
        foreach (var p in m_badEffects.GetComponentsInChildren<ParticleSystem>())
            m_badParticles.Add(new ParticleSystemInfos(p));
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    private void OnGUI()
    {
        if (m_showValueOnGui)
            GUI.Label(new Rect(5, 40, 400, 50), "Balance of coherence :" + m_value);
    }

    void onUpdatingValue()
    {
        if (m_value <= m_minValue)
            onValueMinimal();
        if (m_value >= m_maxValue)
            onValueMaximal();
        execEffect();

        SaveSystem.instance().set("BalanceOfCoherence", m_value);
    }

    void onValueMinimal()
    {
        Event<TimelineDeadEndEvent>.Broadcast(new TimelineDeadEndEvent(10));
    }

    void onValueMaximal()
    {
        //m_value = m_maxValue;
    }

    void execEffect()
    {
        float goodValue = Mathf.Min(m_value > 0 ? m_value / m_maxValue : 0, 1);
        float badValue = Mathf.Min(m_value < 0 ? m_value / m_minValue : 0, 1);

        foreach (var p in m_goodParticles)
            p.set(goodValue);
        foreach (var p in m_badParticles)
            p.set(badValue);

        foreach (var m in m_judeMats)
        {
            m.DOFloat(goodValue, "_Good", m_lerpTime).SetEase(m_lerpShape);
            m.DOFloat(badValue, "_Bad", m_lerpTime).SetEase(m_lerpShape);
        }
    }

    void onEndObjectSelection(AddBalanceOfCoherenceValueEvent e)
    {
        m_value += e.isRightChoice ? m_rightActionValue * e.choiceValue : m_wrongActionValue * e.choiceValue;
        onUpdatingValue();
    }

    void onSetBalanceOfCoherenceValue(SetBalanceOfCoherenceValueEvent e)
    {
        m_value = e.value;
        onUpdatingValue();
    }
}
