using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;
using Sirenix.OdinInspector;

public class ShadowBehaviourLogic : MonoBehaviour
{
    [SerializeField] List<State> m_states = new List<State>();

    Animator m_animator;
    int m_currentIndex = 0;
    float m_currentTime = 0;

    [Serializable]
    public class State
    {
        [ValueDropdown("getAnimationsTypes")]
        public int animationID;
        public float time;
        public bool useTransform;
        [HideIf("useTransform")]
        public Vector3 position;
        [HideIf("useTransform")]
        public Quaternion rotation;
        [ShowIf("useTransform")]
        public Transform transform;

        [HideInInspector] public Transform thisTransform;

        private ValueDropdownList<int> getAnimationsTypes()
        {
            return new ValueDropdownList<int>
        {
            { "1-1-ArmsCrossed", 101 },
            { "1-2-HittingWithLash1", 102 },
            { "1-3-HittingWithLash2Chair", 103 },
            { "1-4-HoldHands", 104 },
            { "1-5-SittingHoldinghands", 105 },
            { "1-6-WalksHandsLeft1", 106 },
            { "1-7-WalksHandsRight1", 107 },
            { "1-8-WalksHandsMiddle1", 108 },
            { "1-9-WalksHandsLeft2", 109 },
            { "1-10-WalkHandsRight2", 110 },
            { "1-11-WalkHandsMuddle2", 111 },

            { "2-5-SitthingHit1", 205 },
            { "2-6-KneeHit1", 206 },
            { "2-7-HittingWithLash2Ground", 207 },
            { "2-7-KneeHit2", 2072 },
            { "2-8-Stomping1", 208 },
            { "2-9-Stomping2", 209 },
            { "2-10-Kicking1", 210 },
            { "2-11-Kicking2", 211 },
            { "2-12-Lying1", 212 },
            { "2-13-Lying2", 213 },
            { "2-14-CarryUnconscious", 214 },
            { "2-15-CarryLeft1", 215 },
            { "2-16-CarryRight1", 216 },
            { "2-17-CarryLeft2", 217 },
            { "2-17-CarryRight2", 2172 },
        };
        }

        [Button]
        void setCurrentTransformPositions()
        {
            if(thisTransform == null)
            {
                Debug.LogError("Current transform can't be found");
                return;
            }

            position = thisTransform.position;
            rotation = thisTransform.rotation;
            useTransform = false;
        }
    }

    void Start()
    {
        m_animator = GetComponent<Animator>();
        updateState();
    }
    
    void Update()
    {
        if (m_states.Count == 0)
            return;

        m_currentTime += Time.deltaTime;
        if(m_currentTime >= m_states[m_currentIndex].time)
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
        if(m_states.Count == 0)
            return;

        var state = m_states[m_currentIndex];
        m_animator.SetInteger("State", state.animationID);
        if(state.useTransform)
        {
            transform.position = state.transform.position;
            transform.rotation = state.transform.rotation;
        }
        else
        {
            transform.rotation = state.rotation;
            transform.position = state.position;
        }

    }

    [OnInspectorGUI]
    void updateStatesTransformRefs()
    {
        foreach (var s in m_states)
            s.thisTransform = transform;
    }

}
