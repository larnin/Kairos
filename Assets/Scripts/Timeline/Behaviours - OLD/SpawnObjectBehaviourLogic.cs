using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;

public class SpawnObjectBehaviourLogic : MonoBehaviour
{
    [SerializeField] List<State> m_states = new List<State>();

    int m_currentIndex = 0;
    float m_currentTime = 0;

    [Serializable]
    public class State
    {
        public float time;
        public GameObject spawnObject;
        public Vector3 offset;
        public Quaternion rotation;
        public float destroyTime;
    }

    void Start()
    {
        updateState();
    }

    void Update()
    {
        if (m_states.Count == 0)
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
        if (m_states.Count == 0)
            return;

        var state = m_states[m_currentIndex];

		if (state.spawnObject == null) return;

        var obj = Instantiate(state.spawnObject, state.offset + transform.position, state.rotation);
		obj.SetActive(true);
        Destroy(obj, state.destroyTime);
    }
}
