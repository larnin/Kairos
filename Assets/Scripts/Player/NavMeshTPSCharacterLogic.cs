using UnityEngine;
using System.Collections;
using UnityEngine.AI;

[RequireComponent(typeof(Rigidbody))]
[RequireComponent(typeof(Animator))]
public class NavMeshTPSCharacterLogic : BaseCharacterLogic
{
    [SerializeField] float m_moveSpeed = 1f;
    [SerializeField] float m_movingTurnSpeed = 360f;
    [SerializeField] float m_stationaryTurnSpeed = 180f;
    [SerializeField] float m_animSpeedMultiplier = 1f;
    [SerializeField] float m_accelerationSpeed = 10f;
    [SerializeField] float m_delayMoveAfterRotation = 0.2f;

    NavMeshAgent m_agent;
    Animator m_animator;

    bool m_moving = false;
    float m_turnAmount = 0;
    float m_targetForwardAmont = 0;
    float m_forwardAmount = 0;
    float m_currentDelay;

    void Awake()
    {
        m_agent = GetComponent<NavMeshAgent>();
        m_animator = GetComponent<Animator>();
    }

    public override void move(Vector3 move)
    {
        const float maxFullAngle = Mathf.PI / 3;
        const float minZeroAngle = 2 * Mathf.PI / 3;

        m_currentDelay += Time.deltaTime;

        move = transform.InverseTransformDirection(move);
        m_turnAmount = Mathf.Atan2(move.x, move.z);
        m_targetForwardAmont = new Vector2(move.x, move.z).magnitude;
        if (Mathf.Abs(m_turnAmount) > maxFullAngle)
        {
            var normalizedAngle = Mathf.Abs(m_turnAmount) - (maxFullAngle);
            normalizedAngle = Mathf.Max(1 - (normalizedAngle / (minZeroAngle - maxFullAngle)), 0);

            m_currentDelay = normalizedAngle * m_delayMoveAfterRotation;
        }

        if (m_currentDelay < m_delayMoveAfterRotation)
            m_targetForwardAmont = 0;

        if (m_forwardAmount < m_targetForwardAmont)
        {
            m_forwardAmount += m_accelerationSpeed * Time.deltaTime;
            if (m_forwardAmount > m_targetForwardAmont)
                m_forwardAmount = m_targetForwardAmont;
        }
        else
        {
            m_forwardAmount -= m_accelerationSpeed * Time.deltaTime;
            if (m_forwardAmount < m_targetForwardAmont)
                m_forwardAmount = m_targetForwardAmont;
        }

        applyExtraTurnRotation();

        updateAnimator(move);

        Vector3 v = m_forwardAmount * transform.forward * m_moveSpeed;
        v.y = m_agent.velocity.y;
        m_agent.velocity = v;
    }

    public bool moving { get { return m_moving; } }


    void applyExtraTurnRotation()
    {
        float turnSpeed = Mathf.Lerp(m_stationaryTurnSpeed, m_movingTurnSpeed, Mathf.Clamp(m_forwardAmount, 0, 1));
        transform.Rotate(0, m_turnAmount * turnSpeed * Time.deltaTime, 0);
    }

    void updateAnimator(Vector3 move)
    {
        m_animator.SetBool("Run", move.sqrMagnitude > 0);

        if (move.sqrMagnitude > 0)
            m_animator.speed = m_animSpeedMultiplier * m_forwardAmount;
        else
            m_animator.speed = 1;
    }

    public void OnAnimatorMove()
    {
        //fuck your animator controls
    }
}