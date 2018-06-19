using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;



public class ModulePlayerSentense : ModuleBase
{
    [Title("Sentense")]
    [HideLabel]
    [MultiLineProperty]
    [SerializeField]
    string m_sentense;

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
        if (m_currentTime >= m_time)
        {
            end();
            m_started = false;
            m_currentTime = 0;
            return true;
        }
        return false;
    }

    void start()
    {
        m_started = true;
        Event<ShowPlayerSentenseEvent>.Broadcast(new ShowPlayerSentenseEvent(m_sentense));
    }

    void end()
    {
        Event<HidePlayerSentenseEvent>.Broadcast(new HidePlayerSentenseEvent());
    }
}