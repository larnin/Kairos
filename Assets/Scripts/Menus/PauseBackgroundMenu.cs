using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;
using System.Collections;

public class PauseBackgroundMenu : MonoBehaviour
{
    public float widthPause = 500;
    public float widthOptions = 500;
    public float widthNotebook = 500;
    public float duration = 1.0f;

    Image m_losange;
    Image m_background;
    Image m_line;
    
    void Start()
    {
        m_losange = transform.Find("Losange").GetComponent<Image>();
        m_background = transform.Find("Back").GetComponent<Image>();
        m_line = transform.Find("Line").GetComponent<Image>();
        m_line.GetComponent<RectTransform>().SetWidth(widthPause, RectTransformExtension.HAlignement.CENTRED);
        m_background.GetComponent<RectTransform>().SetHeight(widthPause, RectTransformExtension.VAlignement.CENTRED);

        onOpen();
    }

    void onOpen()
    {
        m_losange.color = new Color(1, 1, 1, 0);
        m_losange.DOColor(Color.white, duration);
        m_line.color = new Color(1, 1, 1, 0);
        m_line.DOColor(Color.white, duration);
        var tr = m_background.GetComponent<RectTransform>();
        var width = tr.GetWidth();
        tr.SetWidth(0, RectTransformExtension.HAlignement.LEFT);
        DOVirtual.Float(0, width, duration, x => tr.SetWidth(x, RectTransformExtension.HAlignement.LEFT));
    }

    public void setWidth(float width, float delay)
    {
        var lineTransform = m_line.GetComponent<RectTransform>();
        var backTransform = m_background.GetComponent<RectTransform>();
        DOVirtual.Float(lineTransform.GetWidth(), width, delay, x => lineTransform.SetWidth(x, RectTransformExtension.HAlignement.CENTRED));
        DOVirtual.Float(backTransform.GetHeight(), width, delay, x => backTransform.SetHeight(x, RectTransformExtension.VAlignement.CENTRED));
    }

    public void hide(float delay)
    {
        m_losange.DOColor(new Color(1, 1, 1, 0), delay);
        m_background.DOColor(new Color(1, 1, 1, 0), delay);
        m_line.DOColor(new Color(1, 1, 1, 0), delay);
    }
}
