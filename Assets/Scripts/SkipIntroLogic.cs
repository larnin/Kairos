using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.UI;

public class SkipIntroLogic : MonoBehaviour
{
    [SerializeField] List<string> m_inputs;
    [SerializeField] float m_holdTime = 2.0f;
    [SerializeField] float m_showTime = 0.5f;

    float m_hold = 0;
    float m_show = 0;

    Text m_holdText;
    Image m_progressBar;

    bool m_skipped = false;

    private void Start()
    {
        m_holdText = transform.Find("Text").GetComponent<Text>();
        m_progressBar = transform.Find("Image").GetComponent<Image>();
    }

    void Update()
    {
        bool pressed = false;
        foreach(var b in m_inputs)
            if(Input.GetButton(b))
            {
                pressed = true;
                break;
            }

        if (pressed)
        {
            m_hold += Time.deltaTime;
            m_show = Mathf.Min(m_show + Time.deltaTime, m_showTime);
        }
        else
        {
            float holdScale = m_holdTime / m_showTime;
            m_hold = Mathf.Max(0, m_hold - Time.deltaTime * holdScale);
            m_show = Mathf.Max(m_show - Time.deltaTime, 0);
        }

        if (m_hold >= m_holdTime && !m_skipped)
        {
            m_skipped = true;
            Event<StartEndLevelEvent>.Broadcast(new StartEndLevelEvent());
        }

        updateGraphics();
    }

    void updateGraphics()
    {
        float alpha = Mathf.Clamp01(m_show / m_showTime);
        m_holdText.color = new Color(m_holdText.color.r, m_holdText.color.g, m_holdText.color.b, alpha);
        m_progressBar.color = new Color(m_progressBar.color.r, m_progressBar.color.g, m_progressBar.color.b, alpha);
        m_progressBar.transform.localScale = new Vector3(Mathf.Clamp01(m_hold / m_holdTime), 1, 1);
    }
}
