using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.UI;
using DG.Tweening;

public class MainMenuLogic : MonoBehaviour
{
    const string cancelbutton = "Cancel";

    [SerializeField] MainMenuLevelsApparitions m_apparition;
    [SerializeField] string m_firstScene = "Intro";

    Button m_playButton;
    Button m_continueButton;
    Button m_quitButton;

    GameObject m_menuButtonsObjects;

    bool m_onLevelSelection = false;

    private void Awake()
    {
        m_playButton = transform.Find("PlayButton").GetComponent<Button>();
        m_continueButton = transform.Find("ContinueButton").GetComponent<Button>();
        m_quitButton = transform.Find("QuitButton").GetComponent<Button>();
        m_menuButtonsObjects = transform.Find("Levels").gameObject;

        m_menuButtonsObjects.SetActive(false);
    }

    public void onContinueClick()
    {
        var scene = SaveAttributes.getCurrentScene();
        if (scene == " ")
            SceneSystem.changeScene(m_firstScene);
        else SceneSystem.changeScene(scene, false);
    }

    public void onQuitClick()
    {
        Application.Quit();
    }

    private void Update()
    {
        if (m_onLevelSelection && Input.GetButtonDown(cancelbutton))
            setLevelsSubmenu(false);
    }


    public void setLevelsSubmenu(bool value)
    {
        m_playButton.interactable = !value;
        m_continueButton.interactable = !value;
        m_quitButton.interactable = !value;

        if (value)
            m_apparition.show();
        else m_apparition.hide();
        
        m_onLevelSelection = value;

        if (!value)
        {
            foreach (var text in m_menuButtonsObjects.GetComponentsInChildren<Text>())
            {
                text.DOColor(new Color(1.0f, 1.0f, 1.0f, 0.0f), m_apparition.showTime);
            }

            DOVirtual.DelayedCall(0.01f, () => m_playButton.Select());
            DOVirtual.DelayedCall(m_apparition.showTime, () => m_menuButtonsObjects.SetActive(value));
        }
        else
        {
            DOVirtual.DelayedCall(m_apparition.showTime, () =>
            {
                m_menuButtonsObjects.SetActive(value);
                foreach (var text in m_menuButtonsObjects.GetComponentsInChildren<Text>())
                {
                    text.color = new Color(.84f, .84f, .84f, 0);
                    text.DOColor(new Color(.84f, .84f, .84f), m_apparition.showTime);
                }

                DOVirtual.DelayedCall(0.01f, () => m_menuButtonsObjects.GetComponentInChildren<Button>().Select());
            });
        }
    }
}
