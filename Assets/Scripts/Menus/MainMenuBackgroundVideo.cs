using UnityEngine;
using System.Collections;
using UnityEngine.Video;
using DG.Tweening;
using System.Collections.Generic;
using NRand;

public class MainMenuBackgroundVideo : MonoBehaviour
{
    [SerializeField] List<VideoClip> m_videos;
    [SerializeField] float m_delayVideos = 1.0f;
    [SerializeField] float m_fadeTime = 1.0f;

    int m_currenytVideoIndex = -1;

    VideoPlayer m_player;

    bool m_stopped = false;

    private void Awake()
    {
        m_player = GetComponent<VideoPlayer>();

        if (m_videos.Count > 0)
            showNextVideo();
    }

    void showNextVideo()
    {
        if (m_videos.Count == 1)
            m_currenytVideoIndex = 0;
        else
        {
            var gen = new StaticRandomGenerator<DefaultRandomGenerator>();
            var distrib = new UniformIntDistribution(0, m_videos.Count - 1);

            var oldIndex = m_currenytVideoIndex;
            do
            {
                m_currenytVideoIndex = distrib.Next(gen);
            } while (m_currenytVideoIndex == oldIndex);
        }

        m_player.clip = m_videos[m_currenytVideoIndex];
        m_player.targetCameraAlpha = 0;
        DOVirtual.DelayedCall(0.5f, () =>
        {
            if (m_stopped)
                return;
            DOVirtual.Float(0, 1, m_fadeTime, x => m_player.targetCameraAlpha = x);
            DOVirtual.DelayedCall((float)(m_player.clip.length) - m_fadeTime, () => DOVirtual.Float(1, 0, m_fadeTime, x =>
            {
                if(!m_stopped)
                    m_player.targetCameraAlpha = x;
            }));
            DOVirtual.DelayedCall((float)(m_player.clip.length) + m_delayVideos, () =>
            {
                if(!m_stopped)
                    showNextVideo();
            });
        });
    }

    private void OnDestroy()
    {
        m_stopped = true;
    }
}
