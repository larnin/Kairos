using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class CursorLockerlogic : MonoBehaviour
{
    [SerializeField] CursorLockMode m_cursorLockState = CursorLockMode.Confined;

    private void Start()
    {
        Cursor.lockState = m_cursorLockState;
    }
}
