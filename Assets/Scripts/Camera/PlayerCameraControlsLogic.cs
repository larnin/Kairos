using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using DG.Tweening;

public class PlayerCameraControlsLogic : MonoBehaviour
{
    const string camX = "Joy X";
    const string camY = "Joy Y";

    [SerializeField] Ease m_xEase = Ease.Linear;
    [SerializeField] Ease m_yEase = Ease.Linear;
    [SerializeField] float m_xDistance = 1;
    [SerializeField] float m_yDistance = 1;
    [SerializeField] float m_speedX = 1;
    [SerializeField] float m_speedY = 1;

    float m_xValue = 0;
    float m_yValue = 0;

    Camera m_camera;
    Vector3 m_originalPos;

    private void Start()
    {
        m_camera = Camera.main;
        m_originalPos = transform.position;
    }

    private void Update()
    {
        m_xValue = input(camX, m_xValue, m_speedX);
        m_yValue = input(camY, m_yValue, m_speedY);

        float x = DOVirtual.EasedValue(0, 1, Mathf.Abs(m_xValue),m_xEase) * m_xDistance;
        if (m_xValue < 0)
            x = -x;
        float y = DOVirtual.EasedValue(0, 1, Mathf.Abs(m_yValue), m_yEase) * m_yDistance;
        if (m_yValue < 0)
            y = -y;

        transform.position = m_originalPos + m_camera.transform.up * y + m_camera.transform.right * x;
    }

    float input(string axis, float oldValue, float speed)
    {
        float value = Input.GetAxisRaw(axis);

        float delta = value - oldValue;
        oldValue += Mathf.Sign(delta) * speed * Time.deltaTime;

        if (Mathf.Sign(delta) != Mathf.Sign(value - oldValue))
            oldValue = value;
        return oldValue;
    }
}
