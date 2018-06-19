using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;

public class FocusEffectLogic : MonoBehaviour
{
    class InteractableInfos
    {
        public InteractableInfos(GameObject _interactable)
        {
            interactable = _interactable;
            var parent = interactable.transform.parent;
            if (parent != null)
                renderers = parent.GetComponentsInChildren<Renderer>();
        }
        public GameObject interactable;
        public Renderer[] renderers;
    }

    [SerializeField] float m_focusEnterTime = 1;
    [SerializeField] float m_focusExitTime = 1;
    [SerializeField] Material m_postProcessMat;
    [SerializeField] public Light[] m_sceneLights;

    List<Color> m_lightColors = new List<Color>();

    static List<InteractableInfos> m_interactables = new List<InteractableInfos>();

    private void Start()
    {
        m_postProcessMat.SetFloat("_Focus", 0);

        foreach (var l in m_sceneLights)
            m_lightColors.Add(l.color);
    }

    public void startFocus()
    {
        m_postProcessMat.DOFloat(1, "_Focus", m_focusEnterTime);

        foreach(var l in m_sceneLights)
            l.DOColor(Color.white, m_focusEnterTime);

		foreach (var i in m_interactables)
        {
            foreach (var r in i.renderers)
                foreach (var m in r.materials)
                {
                    Material Mat = m;
                    StartCoroutine( manualLerp(m_focusEnterTime, Mat, true) );
                }
        }
    }

    public void endFocus()
    {
        m_postProcessMat.DOFloat(0, "_Focus", m_focusExitTime);

        for (int i = 0; i < m_sceneLights.Length; i++)
            m_sceneLights[i].DOColor(m_lightColors[i], m_focusExitTime);

        foreach (var i in m_interactables)
        {
            foreach (var r in i.renderers)
                foreach (var m in r.materials)
                {
                    
                    Material Mat = m;
                    StartCoroutine(manualLerp(m_focusExitTime, Mat, false));
                }
        }


    }

    public static void registerInteractable(GameObject interactable)
    {
        if(m_interactables.Find(x => x.interactable == interactable) == null)
        {
            m_interactables.Add(new InteractableInfos(interactable));
            foreach(var r in m_interactables[m_interactables.Count - 1].renderers)
                r.material.SetColor("_GlowColor", Color.black);
        }
    }

    public static void unregisterInteractable(GameObject interactable)
    {
        m_interactables.RemoveAll(x => x.interactable == interactable);
    }


    IEnumerator manualLerp(float targetTime, Material Mat, bool enter)
    {
        float time = 0; 

        Color A = enter ? Color.black : Color.white;
        Color B = enter ? Color.white : Color.black;
        
        while (time < targetTime)
        {
            float lerpValue = time/targetTime;
            Color lerped = Color.Lerp(A, B, lerpValue);
            Mat.SetColor("_GlowColor", lerped);
            time += Time.deltaTime;
            yield return null;
        }
    }
}
