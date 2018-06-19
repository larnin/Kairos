using UnityEngine;
using System.Collections;
using DG.Tweening;
using UnityEngine.UI;

public class MainMenuLevelsApparitions : MonoBehaviour
{
    public float showTime = 1;

    GameObject m_levelsBack;
    RectTransform m_horizontalLine;
    RectTransform m_verticalLine;
    RectTransform m_background;

    float m_width;
    float m_height;

    private void Start()
    {
        m_levelsBack = gameObject;
        m_horizontalLine = m_levelsBack.transform.Find("Horizontal").GetComponent<RectTransform>();
        m_verticalLine = m_levelsBack.transform.Find("Vertical").GetComponent<RectTransform>();
        m_background = m_levelsBack.transform.Find("Background").GetComponent<RectTransform>();

        m_width = m_horizontalLine.GetWidth();
        m_height = m_verticalLine.GetHeight();

        m_horizontalLine.SetWidth(0, RectTransformExtension.HAlignement.LEFT);
        m_verticalLine.SetHeight(0, RectTransformExtension.VAlignement.UP);
        m_background.SetHeight(0, RectTransformExtension.VAlignement.UP);
    }

    public void show()
    {
        DOVirtual.Float(0, m_width, showTime, x => m_horizontalLine.SetWidth(x, RectTransformExtension.HAlignement.LEFT)).OnComplete(() =>
        {
            DOVirtual.Float(0, m_height, showTime, x => m_verticalLine.SetHeight(x, RectTransformExtension.VAlignement.UP));
            DOVirtual.Float(0, m_height, showTime, x => m_background.SetHeight(x, RectTransformExtension.VAlignement.UP));
        });
    }

    public void hide()
    {
        var vertical = m_verticalLine.GetComponent<Image>();
        var horizontal = m_horizontalLine.GetComponent<Image>();
        var background = m_background.GetComponent<Image>();

        DOVirtual.Float(1, 0, showTime, x =>
        {
            Color c = new Color(1, 1, 1, x);
            vertical.color = c;
            horizontal.color = c;
            background.color = c;
        }).OnComplete(() =>
        {
            Color c = Color.white;
            vertical.color = c;
            horizontal.color = c;
            background.color = c;

            m_horizontalLine.SetWidth(0, RectTransformExtension.HAlignement.LEFT);
            m_verticalLine.SetHeight(0, RectTransformExtension.VAlignement.UP);
            m_background.SetHeight(0, RectTransformExtension.VAlignement.UP);
        });
    }
}
