using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class MenuSlider : Slider
{
    [SerializeField] FontStyle m_normalStyle = FontStyle.Normal;
    [SerializeField] FontStyle m_highlightedStyle = FontStyle.Normal;
    [SerializeField] FontStyle m_pressedStyle = FontStyle.Normal;
    [SerializeField] FontStyle m_disabledStyle = FontStyle.Normal;

    public FontStyle normalStyle { get { return m_normalStyle; } set { m_normalStyle = value; onStateChange(); } }
    public FontStyle highlightedStyle { get { return m_highlightedStyle; } set { m_highlightedStyle = value; onStateChange(); } }
    public FontStyle pressedStyle { get { return m_pressedStyle; } set { m_pressedStyle = value; onStateChange(); } }
    public FontStyle disabledStyle { get { return m_disabledStyle; } set { m_disabledStyle = value; onStateChange(); } }

    RectTransform m_background;
    RectTransform m_fill;
    float m_height;
    float m_boldHeight;

    Text m_text;

    protected override void Start()
    {
        base.Start();
        m_text = GetComponentInChildren<Text>();
        onStateChange();

        m_background = transform.Find("Background").GetComponent<RectTransform>();
        m_fill = transform.Find("Fill Area").Find("Fill").GetComponent<RectTransform>();
        m_height = m_background.GetHeight();
        m_boldHeight = m_height + 2;
    }

    void onStateChange()
    {
        if (m_text == null || m_background == null || m_fill == null)
            return;

        switch (currentSelectionState)
        {
            case SelectionState.Normal:
                m_text.fontStyle = m_normalStyle;
                m_background.SetHeight(m_height, RectTransformExtension.VAlignement.CENTRED);
                m_fill.SetHeight(m_height, RectTransformExtension.VAlignement.CENTRED);
                break;
            case SelectionState.Highlighted:
                m_text.fontStyle = m_highlightedStyle;
                m_background.SetHeight(m_boldHeight, RectTransformExtension.VAlignement.CENTRED);
                m_fill.SetHeight(m_boldHeight, RectTransformExtension.VAlignement.CENTRED);
                break;
            case SelectionState.Pressed:
                m_text.fontStyle = m_pressedStyle;
                m_background.SetHeight(m_boldHeight, RectTransformExtension.VAlignement.CENTRED);
                m_fill.SetHeight(m_boldHeight, RectTransformExtension.VAlignement.CENTRED);
                break;
            case SelectionState.Disabled:
                m_text.fontStyle = m_disabledStyle;
                m_background.SetHeight(m_height, RectTransformExtension.VAlignement.CENTRED);
                m_fill.SetHeight(m_height, RectTransformExtension.VAlignement.CENTRED);
                break;
        }
    }

    public override void GraphicUpdateComplete()
    {
        base.GraphicUpdateComplete();
        onStateChange();
    }

    public override void LayoutComplete()
    {
        base.LayoutComplete();
        onStateChange();
    }

    public override void OnDrag(PointerEventData eventData)
    {
        base.OnDrag(eventData);
        onStateChange();
    }

    public override void OnInitializePotentialDrag(PointerEventData eventData)
    {
        base.OnInitializePotentialDrag(eventData);
        onStateChange();
    }

    public override void OnMove(AxisEventData eventData)
    {
        base.OnMove(eventData);
        onStateChange();
    }

    public override void OnPointerDown(PointerEventData eventData)
    {
        base.OnPointerDown(eventData);
        onStateChange();
    }

    public override void Rebuild(CanvasUpdate executing)
    {
        base.Rebuild(executing);
        onStateChange();
    }

    protected override void OnDidApplyAnimationProperties()
    {
        base.OnDidApplyAnimationProperties();
        onStateChange();
    }
    
    public override void OnSelect(BaseEventData eventData)
    {
        base.OnSelect(eventData);
        onStateChange();
    }

    public override void Select()
    {
        base.Select();
        onStateChange();
    }

    protected override void OnDisable()
    {
        base.OnDisable();
        onStateChange();
    }

    protected override void OnEnable()
    {
        base.OnEnable();
        onStateChange();
    }

    protected override void OnRectTransformDimensionsChange()
    {
        base.OnRectTransformDimensionsChange();
        onStateChange();
    }

    protected override void Set(float input, bool sendCallback)
    {
        base.Set(input, sendCallback);
        onStateChange();
    }
}

