using UnityEngine;
using System.Collections;

public class RemoveRewindOnEnable : MonoBehaviour
{
    private void OnEnable()
    {
        Event<CleanRewindEvent>.Broadcast(new CleanRewindEvent());
    }
}
