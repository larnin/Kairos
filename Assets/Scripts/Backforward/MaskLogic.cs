using UnityEngine;
using System.Collections;
using Cinemachine;

public class MaskLogic : MonoBehaviour
{
    [SerializeField] CinemachinePathBase m_path;
    [SerializeField] CinemachinePathBase.PositionUnits m_positionUnits = CinemachinePathBase.PositionUnits.Distance;
    [SerializeField] float m_position = 0;
    [SerializeField] float m_speed = 0;

    public GameObject m_rightFeeback = null;
    public GameObject m_wrongFeeback = null;

    [Multiline]
    public string maskText;
    public BaseTextEffectLogic textEffect;

    Vector3 m_baseOffset;

    private void Start()
    {
        m_baseOffset = transform.position - m_path.transform.position;
    }

    void Update()
    {
        setPosition(m_position += m_speed * Time.deltaTime);
    }

    void setPosition(float distanceAlongPath)
    {
        if (m_path != null)
        {
            m_position = m_path.NormalizeUnit(distanceAlongPath, m_positionUnits);
            transform.position = m_path.EvaluatePositionAtUnit(m_position, m_positionUnits) + m_baseOffset;
        }
    }
}
