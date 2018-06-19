using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class TriggerInteractionLogic : MonoBehaviour
{
    [SerializeField] LayerMask m_triggerMask;
    [SerializeField] string m_interactionInput = "Submit";
    [SerializeField] int m_rayCount = 3;
    [SerializeField] float m_rayDelta = 5;
    [SerializeField] float m_rayHeight = 1;
    [SerializeField] float m_rayDistance = 5;

    static List<InteractableLogic> m_interactables = new List<InteractableLogic>();
    InteractableLogic m_hoveredInteractable = null;

    private void OnTriggerEnter(Collider other)
    {
        if ((1 << other.gameObject.layer & m_triggerMask.value) == 0)
            return;

        var triggers = other.GetComponents<TriggerBaseLogic>();
        foreach(var trigger in triggers)
            trigger.onEnter(this);
    }

    private void OnTriggerExit(Collider other)
    {
        if ((1 << other.gameObject.layer & m_triggerMask.value) == 0)
            return;

        var triggers = other.GetComponents<TriggerBaseLogic>();
        foreach (var trigger in triggers)
            trigger.onExit(this);
    }

    public static void registerInteractable(InteractableLogic interactable)
    {
        if (!m_interactables.Contains(interactable))
            m_interactables.Add(interactable);
    }

    public static void unRegisterInteractable(InteractableLogic interactable)
    {
        m_interactables.Remove(interactable);
    }

    private void Update()
    {
        var i = getBestInteractable();
        if (i != null)
        {
            Debug.DrawRay(i.transform.position, Vector3.up, Color.red);
            if(i != m_hoveredInteractable)
            {
                if (m_hoveredInteractable != null)
                    m_hoveredInteractable.onHoverEnd();
                m_hoveredInteractable = i;
                m_hoveredInteractable.onHoverStart();
            }
        }
        else
        {
            if (m_hoveredInteractable != null)
                m_hoveredInteractable.onHoverEnd();
            m_hoveredInteractable = null;
        }

        if (Input.GetButtonDown(m_interactionInput))
        {
            if (i != null)
                i.onInteraction();
        }
    }


    InteractableLogic getBestInteractable()
    {
        for(int i = 0; i < m_rayCount; i++)
        {
            for(int j = -1; j <= 1; j += 2)
            {
                if (i == 0)
                    j = 0;

                var dir = Quaternion.Euler(0, i * m_rayDelta * j, 0) * transform.forward;

                Debug.DrawRay(transform.position + Vector3.up * m_rayHeight - dir, dir * m_rayDistance, Color.cyan);

                Ray r = new Ray(transform.position + Vector3.up * m_rayHeight - dir, dir);

                var hits = Physics.RaycastAll(r, m_rayDistance, m_triggerMask);
                
                foreach(var hit in hits)
                {
                    var interactable = hit.collider.GetComponent<InteractableLogic>();
                    if (interactable != null && m_interactables.Contains(interactable))
                        return interactable;
                }
            }
        }
        return null;
    }

    public static Vector3 NearestPointOnFiniteLine(Vector3 start, Vector3 end, Vector3 pnt, out bool onLine)
    {
        var line = (end - start);
        var len = line.magnitude;
        line /= len;

        var v = pnt - start;
        var d = Vector3.Dot(v, line);
        onLine = d >= 0 && d <= len;
        d = Mathf.Clamp(d, 0f, len);
        return start + line * d;
    }
}