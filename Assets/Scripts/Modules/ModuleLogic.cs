using UnityEngine;
using System.Collections;
using Sirenix.OdinInspector;

public class ModuleLogic : SerializedMonoBehaviour
{
    [SerializeField] ModuleBase m_module;
    [SerializeField] bool m_readStory;

    public ModuleBase module { get { return m_module; } }

    private void Start()
    {
        if (m_readStory)
            StartCoroutine(readStory());
    }

    IEnumerator readStory()
    {
        while(!m_module.update())
        {
            yield return null;
        }
    }
}
