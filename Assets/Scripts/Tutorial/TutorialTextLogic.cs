using UnityEngine;
using System.Collections;
using TMPro;
using DG.Tweening;

public class TutorialTextLogic : MonoBehaviour
{
    TextMeshProUGUI m_text;
    SubscriberList m_subscriberList = new SubscriberList();

    ShowTutorialTextEvent m_currentText = null;
    Color m_textColor;
    Tween m_tween;

    void Start()
    {
        m_text = GetComponent<TextMeshProUGUI>();
        m_textColor = m_text.color;
        m_text.color = new Color(m_textColor.r, m_textColor.g, m_textColor.b, 0);

        m_subscriberList.Add(new Event<ShowTutorialTextEvent>.Subscriber(onShowText));
        m_subscriberList.Add(new Event<StopTutorialTextEvent>.Subscriber(onHideText));
        m_subscriberList.Subscribe();
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    void onShowText(ShowTutorialTextEvent e)
    {
        m_currentText = e;
        startShow();
    }

    void onHideText(StopTutorialTextEvent e)
    {
        endShow();
    }

    void startShow()
    {
        m_text.text = m_currentText.text;
        m_tween = m_text.DOColor(m_textColor, m_currentText.fade).OnComplete(() =>
            {
                if (!m_currentText.noStop)
                    m_tween = DOVirtual.DelayedCall(m_currentText.time - 2 * m_currentText.fade, () => endShow());
            });
    }

    void endShow()
    {
        if (m_currentText == null)
            return;

        if(m_tween != null)
            m_tween.Kill(false);

        m_tween = null;

        m_text.DOColor(new Color(m_textColor.r, m_textColor.g, m_textColor.b, 0), m_currentText.fade);
    }
}
