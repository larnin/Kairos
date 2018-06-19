using UnityEngine;
using System.Collections;

public abstract class InteractableLogic : MonoBehaviour
{
    private void OnEnable()
    {
        TriggerInteractionLogic.registerInteractable(this);
        onEnable();
    }

    protected virtual void onEnable()
    {

    }

    private void OnDisable()
    {
        TriggerInteractionLogic.unRegisterInteractable(this);
        onDisable();
    }

    protected virtual void onDisable()
    {
        
    }

    public abstract void onInteraction();
    public abstract void onHoverStart();
    public abstract void onHoverEnd();
}
