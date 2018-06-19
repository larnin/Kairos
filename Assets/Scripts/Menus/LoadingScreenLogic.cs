using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using DG.Tweening;

public class LoadingScreenLogic : MonoBehaviour
{
    static LoadingScreenLogic m_instance;

    SubscriberList m_subscriberList = new SubscriberList();

    void Awake()
    {
        if (m_instance != null)
        {
            Destroy(gameObject);
            return;
        }
        m_instance = this;
        
        DontDestroyOnLoad(gameObject);

        m_subscriberList.Add(new Event<ShowLoadingScreenEvent>.Subscriber(onShow));
        m_subscriberList.Subscribe();

        gameObject.SetActive(false);
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    void onShow(ShowLoadingScreenEvent e)
    {
        if (e.show)
            show();
        else hide();
    }

    const float backFadeTime = 0.4f;
    const float titleDelay = 0.5f;
    const float titleFade = 0.6f;

    void show()
    {
        gameObject.SetActive(true);

        var background = transform.Find("Image").GetComponent<Graphic>();
        background.color = new Color(0, 0, 0, 0);
        background.DOColor(Color.black, backFadeTime);
        for (int i = 0; i < transform.childCount; i++)
        {
            if (transform.GetChild(i).gameObject == background.gameObject)
                continue;

            foreach (var g in transform.GetChild(i).GetComponentsInChildren<Graphic>())
            {
                g.color = new Color(g.color.r, g.color.g, g.color.b, 0);
                DOVirtual.DelayedCall(backFadeTime + titleDelay, () => g.DOColor(new Color(g.color.r, g.color.g, g.color.b, 1), titleFade));
            }
        }
    }

    void hide()
    {
        var background = transform.Find("Image").GetComponent<Graphic>();

        background.color = Color.black;
        DOVirtual.DelayedCall(titleFade + titleDelay, () => background.DOColor(new Color(0, 0, 0, 0), backFadeTime));

        for (int i = 0; i < transform.childCount; i++)
        {
            if (transform.GetChild(i).gameObject == background.gameObject)
                continue;

            foreach (var g in transform.GetChild(i).GetComponentsInChildren<Graphic>())
            {
                g.color = new Color(g.color.r, g.color.g, g.color.b, 1);
                g.DOColor(new Color(g.color.r, g.color.g, g.color.b, 0), titleFade);
            }
        }

        DOVirtual.DelayedCall(titleFade + titleDelay + backFadeTime, () => gameObject.SetActive(false));
    }
}
