using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using DG.Tweening;

class DemonObjectFeedback : MonoBehaviour
{
    Tween m_tween;
    [SerializeField] GameObject m_feedback = null;

    void Start()
    {
        if (m_feedback == null)
        {
            m_feedback = transform.GetChild(0).gameObject;
        }

		m_feedback.GetComponent<ParticleSystem>().Stop();
    }

    public void hover(bool yes)
    {
		if (yes)
			m_feedback.GetComponent<ParticleSystem>().Play();
		else m_feedback.GetComponent<ParticleSystem>().Stop(false, ParticleSystemStopBehavior.StopEmittingAndClear);
	}
    
}

