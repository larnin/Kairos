using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;


public class ModuleDiorama : ModuleBase
{
    [SerializeField] string m_diorama;

    bool m_started = false;
    bool m_dioramaEnded = false;

    SubscriberList m_subscriberList = new SubscriberList();

    public override bool update()
    {
        if (m_subscriberList == null)
        {
            m_subscriberList = new SubscriberList();
            m_subscriberList.Add(new Event<EndDioramaEvent>.Subscriber(onDioramaEnd));
            m_subscriberList.Add(new Event<DestroyEvent>.Subscriber(onDestroy));
        }

        if (!m_started)
        {
            m_started = true;
            m_subscriberList.Subscribe();
            Event<StartDioramaEvent>.Broadcast(new StartDioramaEvent(m_diorama));
            return false;
        }

        if(m_dioramaEnded)
        {
            m_started = false;
            m_dioramaEnded = false;
            m_subscriberList.Unsubscribe();
            return true;
        }

        return false;
    }

    void onDioramaEnd(EndDioramaEvent e)
    {
        m_dioramaEnded = true;
    }

    void onDestroy(DestroyEvent e)
    {
        m_subscriberList.Unsubscribe();
    }
}
