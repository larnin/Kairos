using UnityEngine;

public class ChangeLightmapEnableEffect : MonoBehaviour
{
    [SerializeField] ChangeLightmap m_lightmapChanger;
    [SerializeField] string m_resourceFolder;

    void OnEnable()
    {
        m_lightmapChanger.Load(m_resourceFolder);
    }
}