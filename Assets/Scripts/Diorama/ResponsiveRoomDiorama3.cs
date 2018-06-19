using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using DG.Tweening;
using TMPro;

class ResponsiveRoomDiorama3 : MonoBehaviour
{
    [SerializeField] Transform m_roomLeft;
    [SerializeField] Transform m_roomRight;
    [SerializeField] Transform m_wall;
    [SerializeField] Transform m_ground;

    [SerializeField] float m_delay = 0.5f;
    [SerializeField] Ease m_easeUsed = Ease.InQuad;
    [SerializeField] float m_stepSizeYWall = 0.5f;
    [SerializeField] float m_stepSizeYGround = 0.01f;
    [SerializeField] float m_decalXRoom =  0.1f;

    int m_currentIncrement = 0;
    
    Tween m_wallTween = null;
    Tween m_roomLeftTween = null;
    Tween m_roomRightTween = null;
    Tween m_groundTween = null;
    
    SubscriberList m_subscriberList = new SubscriberList();

    void Start()
    {
        m_subscriberList.Add(new Event<UpdateIncrementSizeDataEvent>.Subscriber(updateSize));
        m_subscriberList.Subscribe();
    }


    void updateSize(UpdateIncrementSizeDataEvent updateIncrement)
    {
        if(m_wallTween != null)
        {
            m_wallTween.Kill();
        }

        if (m_roomLeftTween != null)
        {
            m_roomLeftTween.Kill();
        }

        if (m_roomRightTween != null)
        {
            m_roomRightTween.Kill();
        }

        if (m_groundTween != null)
        {
            m_groundTween.Kill();
        }

        m_currentIncrement += updateIncrement.increment;

        float targetSize = 1f + m_currentIncrement * m_stepSizeYWall;
        float targetSizeWall = 1f + m_currentIncrement * m_stepSizeYGround;
        float targetPosLeft = m_currentIncrement * m_decalXRoom * (+1);
        float targetPosRight = m_currentIncrement * m_decalXRoom * (-1);

        m_wallTween = m_wall.DOScaleY(targetSize, m_delay).OnComplete( () => {
            Event<RebuildNavmeshEvent>.Broadcast(new RebuildNavmeshEvent());
        });
        m_wallTween.SetEase(m_easeUsed);

        m_groundTween = m_ground.DOScaleY(targetSizeWall, m_delay);
        m_groundTween.SetEase(m_easeUsed); 

        m_roomLeftTween = m_roomLeft.DOMoveX(targetPosLeft, m_delay);
        m_roomLeftTween.SetEase(m_easeUsed);

        m_roomRightTween = m_roomRight.DOMoveX(targetPosRight, m_delay);
        m_roomRightTween.SetEase(m_easeUsed);
    }
}

