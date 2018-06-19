using UnityEngine;

public class ResizeWallIncrementEnableEffect : MonoBehaviour
{
    void OnEnable()
    {
        Event<UpdateIncrementSizeDataEvent>.Broadcast(new UpdateIncrementSizeDataEvent(+1));
    }

    void OnDisable()
    {
        Event<UpdateIncrementSizeDataEvent>.Broadcast(new UpdateIncrementSizeDataEvent(-1));
    }
}