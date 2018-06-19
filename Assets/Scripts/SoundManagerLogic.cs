using UnityEngine;
using System.Collections;
using DG.Tweening;

public class SoundManagerLogic : MonoBehaviour
{

	SubscriberList m_subscriberList = new SubscriberList();
	AudioSource m_audioSource;
	[SerializeField] float m_speedFastForward = 1.2f;
	[SerializeField] float m_speedRewind = -1.2f;


	Tween m_t1;
	Tween m_t2;
	bool m_isRewinding;
	float m_startRewindTime;
	float m_musicStartVolume;

	// Use this for initialization
	void Start()
	{
		m_subscriberList.Add(new Event<TimelineFastForwardEvent>.Subscriber(OnFastForward));
		m_subscriberList.Add(new Event<TimelinePauseEvent>.Subscriber(OnPause));
		m_subscriberList.Add(new Event<TimelineRewindEvent>.Subscriber(OnRewind));
		m_subscriberList.Add(new Event<StartDemonTextInteractionEvent>.Subscriber(OnInteract));
		m_subscriberList.Subscribe();
		m_audioSource = GetComponent<AudioSource>();
		m_musicStartVolume = m_audioSource.volume;
	}

	void Update()
	{
		if (m_audioSource.pitch == -1)
		{
			if (m_audioSource.time == 0)
			{
				
				m_audioSource.time = m_audioSource.clip.length;
			}
		}

		if (m_isRewinding)
		{
			if (Time.time >= m_startRewindTime + 1.5f)
			{
				m_audioSource.pitch = 1;
				m_audioSource.outputAudioMixerGroup.audioMixer.SetFloat("distortionLevel", 0);
				m_audioSource.volume = m_musicStartVolume;
				m_audioSource.time = 7;
				m_isRewinding = false;
			}
		}
	}


	void OnFastForward(TimelineFastForwardEvent e)
	{
		if (e.started)
		{
			
			if (e.forward)
			{
				DOTween.To(() => m_audioSource.pitch, x => m_audioSource.pitch = x, m_speedFastForward, 0.5f);
				DOTween.To(() => m_audioSource.volume, x => m_audioSource.volume = x, 0.2f, 0.5f); 
				m_audioSource.outputAudioMixerGroup.audioMixer.SetFloat("distortionLevel", 0.5f);
				GetComponent<AudioReverbFilter>().reverbPreset = AudioReverbPreset.SewerPipe;
			}
			else
			{			
				m_audioSource.pitch = m_speedRewind;
				m_audioSource.outputAudioMixerGroup.audioMixer.SetFloat("distortionLevel", 0.5f);
				m_audioSource.volume = 0.2f;
				GetComponent<AudioReverbFilter>().reverbPreset = AudioReverbPreset.SewerPipe;
			}
		}
		else
		{
			m_audioSource.pitch = 1;
			m_audioSource.volume = m_musicStartVolume;
			m_audioSource.outputAudioMixerGroup.audioMixer.SetFloat("distortionLevel", 0f);
			GetComponent<AudioReverbFilter>().reverbPreset = AudioReverbPreset.Off;
		}
	}

	void OnPause(TimelinePauseEvent e)
	{
		if (!m_isRewinding)
		{
			if (e.paused)
			{
				m_t1 = DOTween.To(() => m_audioSource.pitch, x => m_audioSource.pitch = x, 0.5f, 0.6f);
				m_t2 = DOTween.To(() => m_audioSource.volume, x => m_audioSource.volume = x, m_musicStartVolume -0.2f, 0.5f);
				GetComponent<AudioReverbFilter>().reverbPreset = AudioReverbPreset.SewerPipe;
				//m_audioSource.pitch = 0.5f;
				//m_audioSource.volume = 0.6f;
			}
			else
			{
				if (m_t1 != null)
					m_t1.Kill();
				if (m_t2 != null)
					m_t2.Kill();
				
				m_t1 = DOTween.To(() => m_audioSource.pitch, x => m_audioSource.pitch = x, 1, 0.5f);
				m_t2 = DOTween.To(() => m_audioSource.volume, x => m_audioSource.volume = x, m_musicStartVolume, 0.5f);
				GetComponent<AudioReverbFilter>().reverbPreset = AudioReverbPreset.Off;
				//m_audioSource.pitch = 1;
				//m_audioSource.volume = 1;
			}
		}
	}

	void OnRewind(TimelineRewindEvent e)
	{
		if (m_t1 != null)
			m_t1.Kill();
		if (m_t2 != null)
			m_t2.Kill();

		DOTween.To(() => m_audioSource.pitch, x => m_audioSource.pitch = x, -1.5f, 0.5f);
		//m_audioSource.pitch = -2;
		m_audioSource.volume = 0.15f;
		m_audioSource.outputAudioMixerGroup.audioMixer.SetFloat("distortionLevel", 0.5f);
		m_isRewinding = true;
		m_startRewindTime = Time.time;
	}

	private void OnDestroy()
	{
		m_subscriberList.Unsubscribe();
	}

	public void OnFolletFootstep(int i)
	{
		AudioSource footstepAudio = transform.GetChild(0).gameObject.GetComponent<AudioSource>();
		footstepAudio.Play();
	}

	void OnInteract(StartDemonTextInteractionEvent e)
	{
		transform.GetChild(1).gameObject.GetComponent<AudioSource>().Play();
	}


}
