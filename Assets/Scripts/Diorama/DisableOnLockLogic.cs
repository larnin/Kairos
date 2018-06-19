using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

class DisableOnLockLogic : MonoBehaviour
{
    SubscriberList m_subscriberList = new SubscriberList();

    private void Awake()
    {
        m_subscriberList.Add(new Event<LockPlayerControlesEvent>.Subscriber(onLock));
        m_subscriberList.Subscribe();
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    void onLock(LockPlayerControlesEvent e)
    {
        gameObject.SetActive(!e.locked);
    }
}