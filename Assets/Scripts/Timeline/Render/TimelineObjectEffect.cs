using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class TimelineObjectEffect : MonoBehaviour
{
    bool m_current = false;
    Image m_centerImage;
    Image m_currentImage;

    private void Awake()
    {
        m_currentImage = transform.Find("Current").GetComponent<Image>();
        m_centerImage = transform.Find("Point").GetComponent<Image>();

        setCurrent(false);
    }

    public void setCurrent(bool current)
    {
        m_current = current;

        if(m_current)
        {
            m_centerImage.gameObject.SetActive(false);
            m_currentImage.gameObject.SetActive(true);
        }
        else
        {
            m_centerImage.gameObject.SetActive(true);
            m_currentImage.gameObject.SetActive(false);
        }
    }
}
