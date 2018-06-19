using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeAssignedSpeaker : MonoBehaviour {

	[SerializeField] GameObject m_newJude;
	[SerializeField] GameObject m_newSelene;
	[SerializeField] MessageBubbleLogic m_dialogueJude;
	[SerializeField] MessageBubbleLogic m_dialogueSelene;

	GameObject m_oldJude;
	GameObject m_oldSelene;

	// Use this for initialization
	void OnEnable()
	{
		m_oldJude = m_dialogueJude.m_assignedSpeaker;
		m_oldSelene = m_dialogueSelene.m_assignedSpeaker;

		m_dialogueJude.m_assignedSpeaker = m_newJude;
		m_dialogueSelene.m_assignedSpeaker = m_newSelene;
	}
}
