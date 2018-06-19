using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using DG.Tweening;
using Sirenix.OdinInspector;
using System.Collections;

public class MaskSelectionLogic : SerializedMonoBehaviour
{
    const string selectButtonButton = "DetectWord";
    const string horizontalAxis = "Horizontal";

    const float m_apparationTime = 3f;
    const float m_effectLenght = 0.8f;
    const float m_colorLenght = 0.5f;
    const float m_normalLightIntensity = 3f;
    const float m_trueLightIntensity = 5f;

    public int m_number = 0;
    [SerializeField] Material m_correctMat;
    public Transform m_pivotMaskEnd = null;

    [SerializeField]  Color redBase;
    [SerializeField]  Color blueBase;


    [SerializeField] Transform m_frontPoint;
    [SerializeField] float m_maskMoveDuration;
    [SerializeField] Ease m_inEase = Ease.Linear;
    [SerializeField] Ease m_outEase = Ease.Linear;
    [SerializeField] MaskLogic m_validMask;
    [SerializeField] MaskEffectBase m_RightMaskEffect;
    [SerializeField] MaskEffectBase m_wrongMaskEffect;
    [SerializeField] MaskEffectBase m_enableMasksEffect;
    [SerializeField] MaskEffectBase m_disableMasksEffect;

    List<MaskLogic> m_masks = new List<MaskLogic>();
    int m_selectedMask = -1;

    bool m_onSelection = false;
    Vector3 m_oldPosition;
    MessageBubbleLogic m_bubble;
    bool m_canInteract;
    bool m_testSet = false;
    bool m_firstTime = true;

    SubscriberList m_maskSubscriberList = new SubscriberList();

    bool m_hasSelectedGoodMask = false;

    bool m_selectionValue;
    State m_currentState;
    
    enum State
    {
        starting,
        running,
        ending
    }

    private void Awake()
    {
        m_maskSubscriberList.Add(new Event<MaskEffectEndEvent>.Subscriber(onMaskEffectEnd));

        for(int i = 0; i < transform.childCount; i++)
        {
            var comp = transform.GetChild(i).GetComponent<MaskLogic>();
            if (comp != null)
                m_masks.Add(comp);
        }

        m_bubble = m_frontPoint.Find("Message").GetComponent<MessageBubbleLogic>();
        m_bubble.gameObject.SetActive(false);
    }

    public void startMasks()
    {

        m_canInteract = false;
        m_onSelection = false;
        m_currentState = State.starting;

        m_maskSubscriberList.Subscribe();

        if (m_enableMasksEffect != null && m_firstTime)
        {
            foreach (var mask in m_masks)
            {
                mask.GetComponentInChildren<Renderer>().material.SetFloat("_Apparition", 0f);
                mask.GetComponentInChildren<Renderer>().material.DOFloat(1, "_Apparition", m_apparationTime);
                Invoke("launchEventMaskEffectEndEvent", m_apparationTime * 0.5f);
            }
            m_firstTime = false;
        }
        else Event<MaskEffectEndEvent>.Broadcast(new MaskEffectEndEvent());
    }

    private void OnDisable()
    {
        selectNext(-1, 0);
        m_maskSubscriberList.Unsubscribe();
    }

    private void OnDestroy()
    {
        m_maskSubscriberList.Unsubscribe();
    }

    private void Update()
    {
        if (m_onSelection || !m_canInteract)
            return;

        if (Input.GetButtonDown(selectButtonButton))
            onSubmit();
        if(Input.GetAxisRaw(horizontalAxis) < -0.5f)
        {
            int index = m_selectedMask - 1;
            if (index < 0)
                index = m_masks.Count - 1;
            selectNext(index, m_maskMoveDuration);
        }
        else if(Input.GetAxisRaw(horizontalAxis) > 0.5f)
        {
            int index = m_selectedMask + 1;
            if (index >= m_masks.Count)
                index = 0;
            selectNext(index, m_maskMoveDuration);
        }
    }

    void selectNext(int nextIndex, float duration)
    {
        if(m_selectedMask != -1)
        {
            m_masks[m_selectedMask].GetComponentInChildren<Light>().DOColor(redBase, m_colorLenght); 
        }

        bool everythingStillExist = true;
        foreach (var m in m_masks)
            if (m == null)
                everythingStillExist = false;
        if (m_onSelection || !everythingStillExist || m_bubble == null || m_currentState != State.running)
            return;

        m_bubble.gameObject.SetActive(false);

        int oldIndex = m_selectedMask;

        if (m_selectedMask != -1)
            m_masks[m_selectedMask].transform.DOMove(m_oldPosition, duration).SetEase(m_outEase)
                .OnComplete(() => { m_masks[oldIndex].enabled = true; });

        m_selectedMask = nextIndex;
        m_onSelection = true;
        if (m_selectedMask == -1)
            DOVirtual.DelayedCall(duration, () => { m_onSelection = false; });
        else
        {
            m_masks[m_selectedMask].enabled = false;
            m_oldPosition = m_masks[m_selectedMask].transform.position;
            m_masks[m_selectedMask].transform.DOMove(m_frontPoint.position, duration).SetEase(m_inEase)
                .OnComplete(() => { onEndMove(); });
        }
    }

    void onEndMove()
    {
        m_onSelection = false;
        if (m_testSet)
            m_bubble.setText("");
        else m_testSet = true;
        DOVirtual.DelayedCall(0.01f, () =>
        {
            if (!m_onSelection)
            {
                m_bubble.gameObject.SetActive(true);
                m_bubble.setText(m_masks[m_selectedMask].maskText);
                m_bubble.setTextEffect(m_masks[m_selectedMask].textEffect);
            }
        });
        m_masks[m_selectedMask].GetComponentInChildren<Light>().DOColor(Color.white, m_colorLenght); 

    }

    void onSubmit()
    {
        m_selectionValue = m_masks[m_selectedMask] == m_validMask;
        Event<MaskSelectedEvent>.Broadcast(new MaskSelectedEvent(m_selectionValue));

        m_canInteract = false;
        m_maskSubscriberList.Subscribe();

        if (m_selectionValue)
        {
            m_hasSelectedGoodMask = true;
            m_masks[m_selectedMask].transform.DOScale(0.15f, 0.7f).SetDelay(0.1f);
            m_masks[m_selectedMask].m_rightFeeback.SetActive(true);
            Invoke("launchEventMaskEffectEndEvent", m_effectLenght*2f);
        }
        else if (!m_selectionValue)
        {
            m_masks[m_selectedMask].m_wrongFeeback.SetActive(true);
            m_masks[m_selectedMask].GetComponentInChildren<Light>().DOColor(redBase, m_colorLenght).onComplete = () =>
            {

                /*
                foreach (var mask in m_masks)
                {
                    mask.GetComponentInChildren<Renderer>().material.SetFloat("_Apparition", 1f);
                    mask.GetComponentInChildren<Renderer>().material.DOFloat(0f, "_Apparition", apparationTime / 2f);
                }
                */
            };
            Invoke("launchEventMaskEffectEndEvent", m_effectLenght*1.25f);
        }
    }

    void startEndMasksEffects()
    {
        m_maskSubscriberList.Subscribe();
        Event<MaskEffectEndEvent>.Broadcast(new MaskEffectEndEvent());
    }

    void onMaskEffectEnd(MaskEffectEndEvent e)
    {
        m_maskSubscriberList.Unsubscribe();
        switch(m_currentState)
        {
            case State.starting:
                m_currentState = State.running;
                m_canInteract = true;
                if (m_selectedMask == 0)
                {
                    selectNext(1, m_maskMoveDuration);
                }
                else
                {
                    selectNext(0, m_maskMoveDuration);
                }

                break;
            case State.running:
                m_currentState = State.ending;
                startEndMasksEffects();
                m_bubble.gameObject.SetActive(false);
                break;
            case State.ending:
                Event<MaskAnswerEvent>.Broadcast(new MaskAnswerEvent(m_selectionValue));
                if(m_masks[m_selectedMask] == m_validMask && m_hasSelectedGoodMask)
                {
                    DOVirtual.DelayedCall(0.25f, () =>
                    {
                        changeMateriaul();
                    });
                    m_masks[m_selectedMask].transform.SetParent(null);
                    m_masks[m_selectedMask].gameObject.SetActive(true);
                    m_masks[m_selectedMask].StartCoroutine(MoveMaskToTransform(m_masks[m_selectedMask].transform, m_pivotMaskEnd.GetChild(m_number)));
                }
                
                break;
        }
    }

    void launchEventMaskEffectEndEvent()
    {
        if(m_selectedMask != -1)
        {
            m_masks[m_selectedMask].m_rightFeeback.SetActive(false);
            m_masks[m_selectedMask].m_wrongFeeback.SetActive(false);
        }
        Event<MaskEffectEndEvent>.Broadcast(new MaskEffectEndEvent());
    }
    

    IEnumerator MoveMaskToTransform(Transform mask, Transform target)
    {
        mask.transform.SetParent(null);
        while (Vector3.Distance(mask.position, target.position) > 0.1f )
        {
            mask.transform.position = Vector3.MoveTowards(mask.transform.position, target.transform.position, Time.deltaTime*25f); 
            yield return null;
        }
        mask.SetParent(target);
        mask.transform.DOLocalRotate(Vector3.zero, 0.5f);
    }
    
    void changeMateriaul()
    {
        m_masks[m_selectedMask].GetComponentInChildren<Light>().enabled = false;
        m_masks[m_selectedMask].transform.GetChild(0).GetComponent<Renderer>().material = m_correctMat;
    }
}
