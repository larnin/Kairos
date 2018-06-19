using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(BaseCharacterLogic))]
class PlayerCharacterControlerLogic : MonoBehaviour
{
    const string moveXAxis = "Horizontal";
    const string moveYAxis = "Vertical";

    [SerializeField] bool m_lockCameraForward = false;

    BaseCharacterLogic m_character;
    Transform m_camera;
    PlayerCameraModifier m_cameraModifier;

    SubscriberList m_subscriberList = new SubscriberList();

    bool m_controlesLocked = false;
    bool m_paused = false;

    Vector3 m_cameraForward;

    private void Awake()
    {
        m_character = GetComponent<BaseCharacterLogic>();

        m_subscriberList.Add(new Event<LockPlayerControlesEvent>.Subscriber(onLockControles));
        m_subscriberList.Add(new Event<PauseEvent>.Subscriber(onPause));
        m_subscriberList.Subscribe();
    }

    private void Start()
    {
        m_camera = Camera.main.transform;
        m_cameraForward = m_camera.forward;
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }
    
    private void Update()
    {
        var dir = new Vector2(Input.GetAxisRaw(moveXAxis), Input.GetAxisRaw(moveYAxis));

        if (m_controlesLocked || m_paused)
            dir = Vector2.zero;

        var camDir = m_lockCameraForward ? m_cameraForward : m_camera.forward;
        var camDir2D = new Vector2(camDir.x, camDir.z).normalized;
        var camDir2DOthro = new Vector2(camDir2D.y, -camDir2D.x);
        dir = dir.y * camDir2D + dir.x * camDir2DOthro;

        var length = dir.magnitude;
        if (length > 1)
            dir /= length;

        if(dir.sqrMagnitude > 0.001f)
            Event<PlayerMovedEvent>.Broadcast(new PlayerMovedEvent());

        m_character.move(new Vector3(dir.x, 0, dir.y));
    }

    void onLockControles(LockPlayerControlesEvent e)
    {
        m_controlesLocked = e.locked;
    }

    void onPause(PauseEvent e)
    {
        m_paused = e.paused;
    }
}