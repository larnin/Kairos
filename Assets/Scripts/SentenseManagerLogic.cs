using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using TMPro;
using System.Collections;

class SentenseManagerLogic : MonoBehaviour
{
    [SerializeField] TextMeshPro m_bossText;
    [SerializeField] TextMeshProUGUI m_bossTextGui;
    [SerializeField] TextMeshProUGUI m_playerTextGui;
    [SerializeField] Camera m_camera;
    [SerializeField] float m_bossTextDistance;
    [SerializeField] List<GameObject> m_choices;

    bool m_bossTextHidden = true;
    SubscriberList m_subscriberList = new SubscriberList();

    Renderer m_bossTextRenderer;

    private void Awake()
    {
        m_subscriberList.Add(new Event<ShowBossSentenseEvent>.Subscriber(onShowBossSentense));
        m_subscriberList.Add(new Event<HideBossSentenseEvent>.Subscriber(onHideBossSentense));
        m_subscriberList.Add(new Event<ShowPlayerSentenseEvent>.Subscriber(onShowPlayerSentense));
        m_subscriberList.Add(new Event<HidePlayerSentenseEvent>.Subscriber(onHidePlayerSentense));
        m_subscriberList.Add(new Event<ShowChoicesEvent>.Subscriber(onShowChoices));
        m_subscriberList.Add(new Event<HideChoicesEvent>.Subscriber(onHideChoices));
        m_subscriberList.Subscribe();
    }

    private void Start()
    {
        m_bossTextRenderer = m_bossText.GetComponent<Renderer>();
        onHideBossSentense(null);
        onHidePlayerSentense(null);
        onHideChoices(null);
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    void onHideBossSentense(HideBossSentenseEvent e)
    {
        m_bossTextHidden = true;
        m_bossText.gameObject.SetActive(false);
        m_bossTextGui.gameObject.SetActive(false);
    }

    void onShowBossSentense(ShowBossSentenseEvent e)
    {
        bool wasHidden = m_bossTextHidden;
        m_bossTextHidden = false;
        placeSentenseInSpace();
        if (wasHidden)
            StartCoroutine(checkSentenseVisibility());
        m_bossText.text = e.sentense;
        m_bossTextGui.text = e.sentense;
        
    }

    void onHidePlayerSentense(HidePlayerSentenseEvent e)
    {
        m_playerTextGui.gameObject.SetActive(false);
    }

    void onShowPlayerSentense(ShowPlayerSentenseEvent e)
    {
        m_playerTextGui.gameObject.SetActive(true);
        m_playerTextGui.text = e.sentense;
    }

    void onShowChoices(ShowChoicesEvent e)
    {
        if(e.choices.Count > m_choices.Count)
        {
            Debug.LogError("Choices count are bigger than the possibilities");
            return;
        }

        for(int i = 0; i < e.choices.Count; i++)
        {
            var c = m_choices[i];
            c.SetActive(true);
            var txt = c.transform.Find("Text").GetComponent<TextMeshProUGUI>();
            if (txt != null)
                txt.text = e.choices[i];
        }
    }

    void onHideChoices(HideChoicesEvent e)
    {
        foreach (var c in m_choices)
            c.SetActive(false);
    }

    IEnumerator checkSentenseVisibility()
    {
        m_bossText.gameObject.SetActive(true);
        while(!m_bossTextHidden)
        {
            m_bossTextGui.gameObject.SetActive(!m_bossTextRenderer.isVisible);
            yield return null;
        }
    }

    void placeSentenseInSpace()
    {
        var pos = m_camera.transform.position + m_camera.transform.forward * m_bossTextDistance;
        m_bossText.transform.position = pos;
        m_bossText.transform.LookAt(m_bossText.transform.position + (m_bossText.transform.position - m_camera.transform.position));
    }

    public void choicePressed(int index)
    {
        Event<ChoiceSelectedEvent>.Broadcast(new ChoiceSelectedEvent(index));
    }
}