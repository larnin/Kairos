using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;

public class LightBehaviourLogic : MonoBehaviour
{
    [SerializeField] GameObject m_lightObject;
    [SerializeField] List<State> m_states = new List<State>();
    
    int m_currentIndex = 0;
    float m_currentTime = 0;

    [Serializable]
    public class State
    {
        public float time;
        public bool enabled;
    }

    void Update()
    {
        if (m_states.Count == 0 || m_lightObject == null)
            return;

        m_currentTime += Time.deltaTime;
        if (m_currentTime >= m_states[m_currentIndex].time)
        {
            m_currentTime = 0;
            m_currentIndex++;
            if (m_currentIndex >= m_states.Count)
                m_currentIndex = 0;
            updateState();
        }
    }

    void updateState()
    {
        if (m_states.Count == 0 || m_lightObject == null)
            return;

        var state = m_states[m_currentIndex];
        m_lightObject.SetActive(state.enabled);
    }
}
