using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class ModuleChoice : ModuleBase
{
    [SerializeField] Choice[] m_choices = new Choice[] { };

    bool m_started = false;
    State m_state = State.NONE;
    int m_selectedSubmodule = 0;
    SubscriberList m_subscriberList = new SubscriberList();
    
    [Serializable]
    public struct Choice
    {
        public string textChoice;
        public ModuleBase module;
        public bool backToChoice;
    }

    enum State
    {
        NONE,
        WAIT_INPUT,
        UPDATING_SUBMODULE,
    }

    public override bool update()
    {
        if(m_subscriberList == null)
        {
            m_subscriberList = new SubscriberList();
            m_subscriberList.Add(new Event<ChoiceSelectedEvent>.Subscriber(onInputEvent));
            m_subscriberList.Add(new Event<DestroyEvent>.Subscriber(onDestroy));
        }

        if (!m_started)
        {
            if (!validateChoices())
                return true;
            m_started = true;
        }

        switch(m_state)
        {
            case State.NONE:
                return stateNone();
            case State.WAIT_INPUT:
                return stateWaitingInput();
            case State.UPDATING_SUBMODULE:
                return stateUpdatingSubmodule();
        }
        Debug.LogError("Invalid module choice behavior !");
        return true;
    }

    bool validateChoices()
    {
        if(m_choices == null)
        {
            Debug.LogError("The choices are null");
            return false;
        }

        foreach(var c in m_choices)
        {
            if(c.module == null)
            {
                Debug.LogError("A module in the choice is null");
                return false;
            }

            if(c.textChoice == "")
            {
                Debug.LogError("There are no text in the choice label");
                return false;
            }
        }

        return true;
    }

    bool stateNone()
    {
        List<string> names = new List<string>();
        foreach (var c in m_choices)
            names.Add(c.textChoice);
        Event<ShowChoicesEvent>.Broadcast(new ShowChoicesEvent(names));
        m_subscriberList.Subscribe();
        m_state = State.WAIT_INPUT;
        return false;
    }

    bool stateWaitingInput()
    {
        return false;
    }

    bool stateUpdatingSubmodule()
    {
        var value = m_choices[m_selectedSubmodule].module.update();
        if (value == false)
            return false;
        m_state = State.NONE;
        return !m_choices[m_selectedSubmodule].backToChoice;
    }

    void onInputEvent(ChoiceSelectedEvent e)
    {
        if(m_state != State.WAIT_INPUT)
        {
            Debug.LogError("Can't do a choice here !");
            return;
        }

        m_selectedSubmodule = e.index;
        if(m_selectedSubmodule < 0 || m_selectedSubmodule >= m_choices.Count())
        {
            Debug.LogError("Invalid choice");
            return;
        }

        m_state = State.UPDATING_SUBMODULE;
        Event<HideChoicesEvent>.Broadcast(new HideChoicesEvent());
        m_subscriberList.Unsubscribe();
    }

    void onDestroy(DestroyEvent e)
    {
        m_subscriberList.Unsubscribe();
    }
}
