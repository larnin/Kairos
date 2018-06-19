using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class DioramaManager : MonoBehaviour
{
    int m_numberOfobjectNeededToWin = 0;
    int m_currentNumberOfWin = 0;

    void Start()
    {
        m_numberOfobjectNeededToWin = FindObjectsOfType<ObjectWithTheDemon2Logic>().Length;
    }

    public void goodAnswer()
    {
        m_currentNumberOfWin++;
        if(m_currentNumberOfWin == m_numberOfobjectNeededToWin)
        {
            print("PlayerWIn");
            // true scene PLAYED !
        }
    }
}

