using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.AI;

public class NavmeshManager : MonoBehaviour
{
    NavMeshSurface m_surface;

    SubscriberList m_subscriberList = new SubscriberList();

    private void Awake()
    {
        m_surface = GetComponent<NavMeshSurface>();

        m_subscriberList.Add(new Event<RebuildNavmeshEvent>.Subscriber(onRebuildNavmesh));
        m_subscriberList.Subscribe();
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    public void onRebuildNavmesh(RebuildNavmeshEvent e)
    {
        m_surface.BuildNavMesh();
    }
}
