using UnityEngine;
using System.Collections;
using Sirenix.OdinInspector;
using System.Collections.Generic;

public class CheatLogic : SerializedMonoBehaviour
{
    [SerializeField] List<BaseCheatEffect> m_cheats = new List<BaseCheatEffect>();

    BaseCheatEffect m_currentCheat = null;

    void Update()
    {
        if(m_currentCheat == null)
        {
            foreach(var c in m_cheats)
                if(Input.GetKeyDown(c.key))
                {
                    m_currentCheat = c;
                    break;
                }
        }
        else if(!m_currentCheat.onUpdate())
            m_currentCheat = null;
    }

    private void OnGUI()
    {
        if (m_currentCheat != null)
            m_currentCheat.onGui();
    }
}
