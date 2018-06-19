using UnityEngine;
using System.Collections;
using UnityEngine.Audio;
using System.Collections.Generic;
using System;
using Sirenix.OdinInspector;

public class AudioSystemLogic : MonoBehaviour
{
    static AudioSystemLogic m_instance;

    [Serializable]
    public class AttenuationVolumeValue
    {
        [HideInInspector] public float baseVolume;
        public string exposedName;
    }

    [SerializeField] AudioMixer m_mixer;
    [SerializeField] List<AttenuationVolumeValue> m_musicVolumes = new List<AttenuationVolumeValue>();
    [SerializeField] List<AttenuationVolumeValue> m_audioVolumes = new List<AttenuationVolumeValue>();

    const float maxValue = -80;

    SubscriberList m_subscriberList = new SubscriberList();

    private void Start()
    {
        if (m_instance == null)
            m_instance = this;
        else
        {
            Destroy(gameObject);
            return;
        }

        DontDestroyOnLoad(gameObject);

        initializeAudio();

        updateMixerVolumes();

        m_subscriberList.Add(new Event<OptionsValueChangedEvent>.Subscriber(onOptionsChanges));
        m_subscriberList.Subscribe();
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    void initializeAudio()
    {
        foreach (var v in m_musicVolumes)
            m_mixer.GetFloat(v.exposedName, out v.baseVolume);

        foreach (var v in m_audioVolumes)
            m_mixer.GetFloat(v.exposedName, out v.baseVolume);
    }
    
    void updateMixerVolumes()
    {
        foreach (var v in m_musicVolumes)
        {
            float input = Mathf.Pow(2, 1 - Options.instance.musicValue) - 1;
            input = Mathf.Pow(2, input) - 1;
            float value = (maxValue - v.baseVolume) * input + v.baseVolume;
            m_mixer.SetFloat(v.exposedName, value);

        }

        foreach (var v in m_audioVolumes)
        {
            float input = Mathf.Pow(2, 1 - Options.instance.audioValue) - 1;
            input = Mathf.Pow(2, input) - 1;
            float value = (maxValue - v.baseVolume) * input + v.baseVolume;
            m_mixer.SetFloat(v.exposedName, value);
        }
    }

    void onOptionsChanges(OptionsValueChangedEvent e)
    {
        updateMixerVolumes();
    }
}