using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.SceneManagement;


public class LowBudgetIntroductionLogic : MonoBehaviour
{
    const string submitButton = "Submit";

    [SerializeField] List<GameObject> m_messages;
    [SerializeField] string m_nextSceneName;

    int m_messageIndex = -1;

    private void Start()
    {
        foreach (var g in m_messages)
            g.SetActive(false);

        enableNextMessage();
    }

    private void Update()
    {
        if (Input.GetButtonDown(submitButton))
            enableNextMessage();
    }

    void enableNextMessage()
    {
        if (m_messageIndex < m_messages.Count)
        {
            if (m_messageIndex >= 0)
                m_messages[m_messageIndex].SetActive(false);
            m_messageIndex++;
            if (m_messageIndex < m_messages.Count)
                m_messages[m_messageIndex].SetActive(true);
        }
        else SceneSystem.changeScene(m_nextSceneName);
    }
}