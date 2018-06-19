using UnityEngine;
using System.Collections;

public class PauseLogic : MonoBehaviour
{
    [SerializeField] GameObject m_prefab;
    bool m_paused = false;
    SubscriberList m_subscriberList = new SubscriberList();

    private void Awake()
    {
        m_subscriberList.Add(new Event<PauseEvent>.Subscriber(onPause));
        m_subscriberList.Subscribe();
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    void onPause(PauseEvent e)
    {
        m_paused = e.paused;
    }

    void Update()
    {
        if (!m_paused && Input.GetButtonDown("Pause"))
            Instantiate(m_prefab);
    }
}
