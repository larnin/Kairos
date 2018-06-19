using UnityEngine;
using System.Collections;

public abstract class BaseUpdatableLogic : MonoBehaviour
{
    public enum UpdateType
    {
        UPDATE,
        LATE_UPDATE,
        FIXED_UPDATE,
    }

    [SerializeField] protected UpdateType m_updateType = UpdateType.UPDATE;

    private void Update()
    {
        if (Time.deltaTime > 0 && m_updateType == UpdateType.UPDATE)
            onUpdate();
    }

    private void FixedUpdate()
    {
        if (Time.deltaTime > 0 && m_updateType == UpdateType.FIXED_UPDATE)
            onUpdate();
    }

    private void LateUpdate()
    {
        if (Time.deltaTime > 0 && m_updateType == UpdateType.LATE_UPDATE)
            onUpdate();
    }

    protected abstract void onUpdate();
}
