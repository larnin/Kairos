using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LookAtPlayerOnEnable : MonoBehaviour {

	[SerializeField] List<GameObject> m_charactersToTurn = new List<GameObject>();
	[SerializeField] GameObject m_player;

	List<Vector3> m_positions = new List<Vector3>();
	List<Quaternion> m_rotations = new List<Quaternion>();
	bool m_isGoing;
	
	void Update () {
		if (m_isGoing)
		{
			foreach (GameObject character in m_charactersToTurn)
			{
				Vector3 charRot = character.transform.eulerAngles;
				character.transform.LookAt(m_player.transform);
				character.transform.eulerAngles = new Vector3(charRot.x, character.transform.eulerAngles.y, charRot.z);
			}
		}
	}

	private void OnEnable()
	{
		foreach (GameObject character in m_charactersToTurn)
		{
			m_positions.Add(character.transform.position);
			m_rotations.Add(character.transform.rotation);
		}
		m_isGoing = true;
	}

	private void OnDisable()
	{
		int i = 0;
		foreach (GameObject character in m_charactersToTurn)
		{
			character.transform.position = m_positions[i];
			character.transform.rotation = m_rotations[i];
			i++;
		}
		m_isGoing = false;
	}


}
