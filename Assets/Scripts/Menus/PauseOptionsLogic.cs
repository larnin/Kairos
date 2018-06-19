using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using DG.Tweening;

public class PauseOptionsLogic : MonoBehaviour
{
    Slider m_soundSlider;
    Slider m_musicSlider;
    Slider m_sceneSpeedSlider;

    void Awake()
    {
        m_soundSlider = transform.Find("SoundSlider").GetComponent<Slider>();
        m_musicSlider = transform.Find("MusicSlider").GetComponent<Slider>();
        m_sceneSpeedSlider = transform.Find("SceneSpeedSlider").GetComponent<Slider>();
    }

    private void OnEnable()
    {
        m_soundSlider.value = Options.instance.audioValue;
        m_musicSlider.value = Options.instance.musicValue;
        m_sceneSpeedSlider.value = Options.instance.timelineSpeed;
        DOVirtual.DelayedCall(0.01f, () => { m_soundSlider.Select(); });
    }

    public void onAudioValueChanged()
    {
        Options.instance.audioValue = m_soundSlider.value;
        Event<OptionsValueChangedEvent>.Broadcast(new OptionsValueChangedEvent());
    }

    public void onMusicValueChanged()
    {
        Options.instance.musicValue = m_musicSlider.value;
        Event<OptionsValueChangedEvent>.Broadcast(new OptionsValueChangedEvent());
    }

    public void onTimelineSpeedValueChanged()
    {
        Options.instance.timelineSpeed = Mathf.RoundToInt(m_sceneSpeedSlider.value);
        Event<OptionsValueChangedEvent>.Broadcast(new OptionsValueChangedEvent());
    }
}
