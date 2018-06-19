using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using DG.Tweening;

public class PauseMenuLogic : MonoBehaviour
{
    const string mainMenuName = "MainMenu";

    [SerializeField] PauseBackgroundMenu m_backgroundEffect;

    GameObject m_pauseMenu;
    GameObject m_optionsMenu;
    GameObject m_notebookMenu;

    private void Awake()
    {
        m_pauseMenu = transform.Find("PauseMenu").gameObject;
        m_optionsMenu = transform.Find("OptionsMenu").gameObject;
        m_notebookMenu = transform.Find("NotebookMenu").gameObject;

        m_pauseMenu.SetActive(false);
        m_optionsMenu.SetActive(false);
        m_notebookMenu.SetActive(false);
    }

    private void Start()
    {
        showMenu(m_pauseMenu, m_backgroundEffect.duration);
        Event<PauseEvent>.Broadcast(new PauseEvent(true));
    }

    public void onStopTutoPress()
    {
        Event<StopTutoEvent>.Broadcast(new StopTutoEvent());
        onResumePress();
    }

    public void onResumePress()
    {
        m_backgroundEffect.hide(m_backgroundEffect.duration);
        hideMenu(m_pauseMenu, m_backgroundEffect.duration);
        DOVirtual.DelayedCall(m_backgroundEffect.duration, () =>
        {
            Event<PauseEvent>.Broadcast(new PauseEvent(false));
            Destroy(gameObject);
        });
    }

    public void onNotebookPress()
    {
        m_backgroundEffect.setWidth(m_backgroundEffect.widthNotebook, m_backgroundEffect.duration);

        hideMenu(m_pauseMenu, m_backgroundEffect.duration / 2);
        DOVirtual.DelayedCall(m_backgroundEffect.duration / 2 , () => showMenu(m_notebookMenu, m_backgroundEffect.duration / 2));
    }

    public void onOptionsPress()
    {
        m_backgroundEffect.setWidth(m_backgroundEffect.widthOptions, m_backgroundEffect.duration);

        hideMenu(m_pauseMenu, m_backgroundEffect.duration / 2);
        DOVirtual.DelayedCall(m_backgroundEffect.duration / 2, () => showMenu(m_optionsMenu, m_backgroundEffect.duration / 2));
    }

    public void onMainMenuPress()
    {
        SceneSystem.changeScene(mainMenuName, false);
    }

    public void onReturnPauseMenu()
    {
        m_backgroundEffect.setWidth(m_backgroundEffect.widthPause, m_backgroundEffect.duration);

        hideMenu(m_optionsMenu, m_backgroundEffect.duration / 2);
        hideMenu(m_notebookMenu, m_backgroundEffect.duration / 2);
        DOVirtual.DelayedCall(m_backgroundEffect.duration / 2, () => showMenu(m_pauseMenu, m_backgroundEffect.duration / 2));
    }

    private void Update()
    {
        if (Input.GetButtonDown("Cancel"))
            onCancel();
    }

    void onCancel()
    {
        if (m_pauseMenu.activeSelf)
            onResumePress();
        else onReturnPauseMenu();
    }

    void hideMenu(GameObject parent, float time)
    {
        if (!parent.activeSelf)
            return;

        foreach (var t in parent.GetComponentsInChildren<Graphic>())
        {
            Color c = t.color;
            t.DOColor(new Color(c.r, c.g, c.b, 0), time);
        }
        DOVirtual.DelayedCall(time, () => parent.SetActive(false));
    }

    void showMenu(GameObject parent, float time)
    {
        if (parent.activeSelf)
            return;

        parent.SetActive(true);
        foreach (var t in parent.GetComponentsInChildren<Graphic>())
        {
            Color c = t.color;
            c.a = 1;
            t.color = new Color(c.r, c.g, c.b, 0);
            t.DOColor(c, time);
        }

    }
}
