using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ModuleDemonSentense : ModuleBase
{
    [Title("Sentense")]
    [HideLabel]
    [MultiLineProperty]
    [SerializeField] string m_sentense;

    [SerializeField] float m_time;

    float m_currentTime = 0;
    bool m_started = false;

    public override bool update()
    {
        if (!m_started)
        {
            start();
            return false;
        }

        m_currentTime += Time.deltaTime;
        if(m_currentTime >= m_time)
        {
            end();
            m_currentTime = 0;
            m_started = false;
            return true;
        }
        return false;
    }

    void start()
    {
        m_started = true;
        Event<ShowBossSentenseEvent>.Broadcast(new ShowBossSentenseEvent(m_sentense));
    }

    void end()
    {
        Event<HideBossSentenseEvent>.Broadcast(new HideBossSentenseEvent());
    }
}