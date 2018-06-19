using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class DestroyCkeckerLogic : MonoBehaviour
{
    private void OnDestroy()
    {
        Event<DestroyEvent>.Broadcast(new DestroyEvent());
    }
}
