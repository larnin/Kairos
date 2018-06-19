using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using DG.Tweening;

public class MenuButton : Button
{
    [SerializeField] FontStyle m_normalStyle = FontStyle.Normal;
    [SerializeField] FontStyle m_highlightedStyle = FontStyle.Normal;
    [SerializeField] FontStyle m_pressedStyle = FontStyle.Normal;
    [SerializeField] FontStyle m_disabledStyle = FontStyle.Normal;

    public FontStyle normalStyle { get { return m_normalStyle; } set { m_normalStyle = value; onStateChange(); } }
    public FontStyle highlightedStyle { get { return m_highlightedStyle; } set { m_highlightedStyle = value; onStateChange(); } }
    public FontStyle pressedStyle { get { return m_pressedStyle; } set { m_pressedStyle = value; onStateChange(); } }
    public FontStyle disabledStyle { get { return m_disabledStyle; } set { m_disabledStyle = value; onStateChange(); } }

    Text m_text;

    protected override void Start()
    {
        base.Start();
        m_text = GetComponentInChildren<Text>();
        onStateChange();
        DOVirtual.DelayedCall(0.01f, onStateChange);
    }

    protected override void Awake()
    {
        base.Awake();
        m_text = GetComponentInChildren<Text>();
        onStateChange();
        DOVirtual.DelayedCall(0.01f, onStateChange);
    }

    void onStateChange()
    {
        if (m_text == null)
            return;

        SelectionState state = currentSelectionState;

        if (!interactable)
            state = SelectionState.Disabled;

        switch (state)
        {
            case SelectionState.Normal:
                m_text.fontStyle = m_normalStyle;
                break;
            case SelectionState.Highlighted:
                m_text.fontStyle = m_highlightedStyle;
                break;
            case SelectionState.Pressed:
                m_text.fontStyle = m_pressedStyle;
                break;
            case SelectionState.Disabled:
                m_text.fontStyle = m_disabledStyle;
                break;
        }
    }

    public override void OnPointerClick(PointerEventData eventData)
    {
        base.OnPointerClick(eventData);
        onStateChange();
    }
    public override void OnSubmit(BaseEventData eventData)
    {
        base.OnSubmit(eventData);
        onStateChange();
    }
    
    public override bool IsInteractable()
    {
        var b = base.IsInteractable();
        onStateChange();
        return b;
    }

    public override void OnDeselect(BaseEventData eventData)
    {
        base.OnDeselect(eventData);
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

    public override void OnPointerEnter(PointerEventData eventData)
    {
        base.OnPointerEnter(eventData);
        onStateChange();
    }

    public override void OnPointerExit(PointerEventData eventData)
    {
        base.OnPointerExit(eventData);
        onStateChange();
    }

    public override void OnPointerUp(PointerEventData eventData)
    {
        base.OnPointerUp(eventData);
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
}
