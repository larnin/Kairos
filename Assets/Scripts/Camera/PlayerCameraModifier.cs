using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class PlayerCameraModifier : MonoBehaviour, ICameraModifier
{
    string mouseXAxisName = "Mouse X";
    string mouseYAxisName = "Mouse Y";
    string joystickXAxisName = "Joy X";
    string joystickYAxisName = "Joy Y";

    [SerializeField] float m_rotSpeedX = 1;
    [SerializeField] float m_rotSpeedY = 1;
    [SerializeField] bool m_reverseVertical = false;
    [SerializeField] float m_recenterDelay = 0.5f;
    [SerializeField] float m_recenterSpeed = 1;
    
    [ToggleGroup("m_offsetPositionX", order: -1, groupTitle: "Position X")]
    [SerializeField] bool m_offsetPositionX = true;
    [ToggleGroup("m_offsetPositionX")] [LabelText("Position X")]
    [SerializeField] AnimationCurve m_curvePosXX;
    [ToggleGroup("m_offsetPositionX")] [LabelText("Position Y")]
    [SerializeField] AnimationCurve m_curvePosYX;
    [ToggleGroup("m_offsetPositionX")] [LabelText("Position Z")]
    [SerializeField] AnimationCurve m_curvePosZX;

    [ToggleGroup("m_offsetTargetX", order: -1, groupTitle: "Target X")]
    [SerializeField] bool m_offsetTargetX = true;
    [ToggleGroup("m_offsetTargetX")] [LabelText("Target X")]
    [SerializeField] AnimationCurve m_curveTargetXX;
    [ToggleGroup("m_offsetTargetX")] [LabelText("Targer Y")]
    [SerializeField] AnimationCurve m_curveTargetYX;
    [ToggleGroup("m_offsetTargetX")] [LabelText("Target Z")]
    [SerializeField] AnimationCurve m_curveTargetZX;

    [ToggleGroup("m_offsetRotationX", order: -1, groupTitle: "Rotation X")]
    [SerializeField] bool m_offsetRotationX = true;
    [ToggleGroup("m_offsetRotationX")] [LabelText("Rotation X")]
    [SerializeField] AnimationCurve m_curveAngleXX;
    [ToggleGroup("m_offsetRotationX")] [LabelText("Rotation Y")]
    [SerializeField] AnimationCurve m_curveAngleYX;
    [ToggleGroup("m_offsetRotationX")] [LabelText("Rotation Z")]
    [SerializeField] AnimationCurve m_curveAngleZX;

    [ToggleGroup("m_offsetPositionY", order: -1, groupTitle: "Position Y")]
    [SerializeField] bool m_offsetPositionY = true;
    [ToggleGroup("m_offsetPositionY")] [LabelText("Position X")]
    [SerializeField] AnimationCurve m_curvePosXY;
    [ToggleGroup("m_offsetPositionY")] [LabelText("Position Y")]
    [SerializeField] AnimationCurve m_curvePosYY;
    [ToggleGroup("m_offsetPositionY")] [LabelText("Position Z")]
    [SerializeField] AnimationCurve m_curvePosZY;

    [ToggleGroup("m_offsetTargetY", order: -1, groupTitle: "Target Y")]
    [SerializeField] bool m_offsetTargetY = true;
    [ToggleGroup("m_offsetTargetY")] [LabelText("Target X")]
    [SerializeField] AnimationCurve m_curveTargetXY;
    [ToggleGroup("m_offsetTargetY")] [LabelText("Target Y")]
    [SerializeField] AnimationCurve m_curveTargetYY;
    [ToggleGroup("m_offsetTargetY")] [LabelText("Target Z")]
    [SerializeField] AnimationCurve m_curveTargetZY;

    [ToggleGroup("m_offsetRotationY", order: -1, groupTitle: "Rotation Y")]
    [SerializeField]
    bool m_offsetRotationY = true;
    [ToggleGroup("m_offsetRotationY")] [LabelText("Rotation X")]
    [SerializeField] AnimationCurve m_curveAngleXY;
    [ToggleGroup("m_offsetRotationY")] [LabelText("Rotation Y")]
    [SerializeField] AnimationCurve m_curveAngleYY;
    [ToggleGroup("m_offsetRotationY")] [LabelText("Rotation Z")]
    [SerializeField] AnimationCurve m_curveAngleZY;


    Vector2 m_currentRot = new Vector2();
    float m_timeAfterLastinput = 0;

    private void OnEnable()
    {
        CameraLogic.registerModifier(this);
    }

    private void OnDisable()
    {
        CameraLogic.unregisterModifier(this);
    }

    public CameraOffsetInfos check(Vector3 position)
    {
        updateControls();

        var cam = new CameraOffsetInfos();

        if(m_offsetPositionX)
            cam.positionOffset += new Vector3(m_curvePosXX.Evaluate(m_currentRot.x), m_curvePosYX.Evaluate(m_currentRot.x), m_curvePosZX.Evaluate(m_currentRot.x));
        if(m_offsetTargetX)
            cam.targetOffset += new Vector3(m_curveTargetXX.Evaluate(m_currentRot.x), m_curveTargetYX.Evaluate(m_currentRot.x), m_curveTargetZX.Evaluate(m_currentRot.x));
        if(m_offsetRotationX)
            cam.eulerRotationOffset += new Vector3(m_curveAngleXX.Evaluate(m_currentRot.x), m_curveAngleYX.Evaluate(m_currentRot.x), m_curveAngleZX.Evaluate(m_currentRot.x));

        if(m_offsetPositionY)
            cam.positionOffset += new Vector3(m_curvePosXY.Evaluate(m_currentRot.y), m_curvePosYY.Evaluate(m_currentRot.y), m_curvePosZY.Evaluate(m_currentRot.y));
        if (m_offsetTargetY)
            cam.targetOffset += new Vector3(m_curveTargetXY.Evaluate(m_currentRot.y), m_curveTargetYY.Evaluate(m_currentRot.y), m_curveTargetZY.Evaluate(m_currentRot.y));
        if (m_offsetRotationY)
            cam.eulerRotationOffset += new Vector3(m_curveAngleXY.Evaluate(m_currentRot.y), m_curveAngleYY.Evaluate(m_currentRot.y), m_curveAngleZY.Evaluate(m_currentRot.y));

        return cam;
    }

    void updateControls()
    {
        Vector2 dir = new Vector2(Input.GetAxisRaw(mouseXAxisName) + Input.GetAxisRaw(joystickXAxisName), (Input.GetAxisRaw(mouseYAxisName) + Input.GetAxisRaw(joystickYAxisName)) * (m_reverseVertical ? -1 : 1));

        if(dir.sqrMagnitude < 0.1f)
        {
            m_timeAfterLastinput += Time.deltaTime;
            if (m_timeAfterLastinput > m_recenterDelay)
                recenter();
        }
        else
        {
            m_timeAfterLastinput = 0;
            m_currentRot += Vector2.Scale(dir * Time.deltaTime, new Vector3(m_rotSpeedX, m_rotSpeedY));
            m_currentRot.x = Mathf.Clamp(m_currentRot.x, -1, 1);
            m_currentRot.y = Mathf.Clamp(m_currentRot.y, -1, 1);
        }
        
    }

    void recenter()
    {
        Vector2 dir = -m_currentRot.normalized * Time.deltaTime * m_recenterSpeed;
        if (dir.sqrMagnitude > m_currentRot.sqrMagnitude)
            dir = -m_currentRot;
        m_currentRot += dir;
    }
}