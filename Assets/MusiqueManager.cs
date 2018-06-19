using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class MusiqueManager : MonoBehaviour {


	[SerializeField] AudioSource m_initialMusiqueSource;
	[SerializeField] AudioSource m_crossfadeMusicSource;
	[SerializeField] List<AudioClip> m_musics = new List<AudioClip>();
	static int m_currentMusic = 0;
	float m_musicVolume;

	// Use this for initialization
	void Start () {
		m_initialMusiqueSource.clip = m_musics[0];
		m_initialMusiqueSource.Play();
		m_musicVolume = m_initialMusiqueSource.volume;
	}

	public void TransitionMusic(bool change, float newVolume)
	{
		m_currentMusic += 1;
		m_crossfadeMusicSource.volume = 0;
		m_crossfadeMusicSource.clip = m_musics[m_currentMusic];
		m_crossfadeMusicSource.Play();
		if (change)
		{
			DOTween.To(() => m_crossfadeMusicSource.volume, x => m_crossfadeMusicSource.volume = x, newVolume, 1f);
			DOTween.To(() => m_initialMusiqueSource.volume, x => m_initialMusiqueSource.volume = x, 0, 1f);
			StartCoroutine(changeMusic(newVolume));
		}
		else
		{
			DOTween.To(() => m_crossfadeMusicSource.volume, x => m_crossfadeMusicSource.volume = x, m_musicVolume, 1f);
			DOTween.To(() => m_initialMusiqueSource.volume, x => m_initialMusiqueSource.volume = x, 0, 1f);
			StartCoroutine(changeMusic(m_musicVolume));
		}
		
	}

    public void GoBack()
    {
        if (m_crossfadeMusicSource != null && m_initialMusiqueSource != null)
        {
            m_currentMusic -= 1;
            m_crossfadeMusicSource.volume = 0;
            m_crossfadeMusicSource.clip = m_musics[m_currentMusic];
            m_crossfadeMusicSource.Play();
            DOTween.To(() => m_crossfadeMusicSource.volume, x => m_crossfadeMusicSource.volume = x, m_musicVolume, 1f);
            DOTween.To(() => m_initialMusiqueSource.volume, x => m_initialMusiqueSource.volume = x, 0, 1f);
            StartCoroutine(changeMusic(m_musicVolume));
        }
    }

	IEnumerator changeMusic(float volume)
	{
		yield return new WaitForSeconds(1.1f);
		m_initialMusiqueSource.clip = m_musics[m_currentMusic];
		m_initialMusiqueSource.volume = volume;
		m_initialMusiqueSource.time = m_crossfadeMusicSource.time;
		m_initialMusiqueSource.Play();
		m_crossfadeMusicSource.Stop();
	}	
	
}
