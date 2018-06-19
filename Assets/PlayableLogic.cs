using UnityEngine;
using System.Collections;
using UnityEngine.Playables;

public class PlayableLogic : MonoBehaviour
{
	[SerializeField] float m_timeScale = 1;
	PlayableDirector m_director;
	float m_currentTime = 0;

	void Awake()
	{
		m_director = GetComponent<PlayableDirector>();
		m_director.timeUpdateMode = DirectorUpdateMode.Manual;
		m_director.Play();
	}

	private void OnEnable()
	{
		m_currentTime = 0;
		m_director.Play();
	}

	private void OnDisable()
	{
		m_currentTime = 0;
		m_director.Stop();
	}

	void Update()
	{
		if(m_director.time < m_director.duration)
		{
			m_currentTime += Time.deltaTime * m_timeScale;
			m_director.time = m_currentTime;
			m_director.Evaluate();
		}
	}
}