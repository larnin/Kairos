using DG.Tweening;
using System;
using System.Collections.Generic;
using UnityEngine;

class ResponsiveUIChoiceSystem : MonoBehaviour
{
    const int noSelection = -1;
    const float delayTime = 0.25f;
    
    [SerializeField] GameObject m_bublesPrefab = null;
    [SerializeField] float m_distance = 350f;
    [SerializeField] float m_borderX = 20f;
    [SerializeField] float m_borderY = 20f;
    [SerializeField] Vector3 m_offset = new Vector3(0f, 1.55f, 0f);
    [SerializeField] Transform m_playerTransform;
    [SerializeField] float newSizeWhenSelected = 2f;

    [SerializeField] Material m_baseMaterial;
    [SerializeField] Material m_whenSelected;
    [SerializeField] Material m_whenCorrect;
    [SerializeField] Material m_whenWrong;


    TMPro.TMP_Text m_textMeshOldSelected;
    TMPro.TMP_Text m_textMeshCurrentSelected;
    float m_lerpForCurrent = 0f;
    float m_lerpForOld = 0f;

    int m_numberChoice = 1;
    Transform m_pivot = null;
    int m_selectedChoice = -1;
    Canvas m_mainCanvas = null;

    bool m_noInput = false;
    
    Transform[] m_choices;
    List<int> m_correctChoice;
    
    float m_rightMaxX;
    float m_rightMinX;

    float m_leftMaxX;
    float m_leftMinX;

    float m_distanceForRightSide;
    float m_distanceForLeftSide;

    float m_extentsYMaximumOnLeftRightBubles;
    float m_extentsYMaximumOnMiddleBubles;
    float m_extentsYForLeft;
    float m_extentsYForRight;

    SubscriberList m_subscriberList = new SubscriberList();

    float targetOpacity;

    public Color blueOfPaul;
    public Color redOfPaul;

    public Camera m_demonCamera;
    public GameObject m_goodParticle;
    public GameObject m_badParticle;

    void Start()
    {
        m_subscriberList.Add(new Event<UpdateAdaptiveUIDataEvent>.Subscriber(OnUpdateData));
        m_subscriberList.Add(new Event<StopAdaptiveUIUIDataEvent>.Subscriber(Reset));
        m_subscriberList.Add(new Event<FeedbackSelectedAdaptiveUIDataEvent>.Subscriber(FeedBackOnSelectedUI));
        m_subscriberList.Subscribe();
        enabled = false;
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    private TMPro.TextMeshProUGUI getTextMesh(int index)
    {
        return m_choices[index].GetComponentInChildren<TMPro.TextMeshProUGUI>();
    }

    private void FeedBackOnSelectedUI(FeedbackSelectedAdaptiveUIDataEvent feedbackSelectedAdaptiveUIDataEvent)
    {
        TMPro.TextMeshProUGUI TextMesh = getTextMesh(feedbackSelectedAdaptiveUIDataEvent.numero);
        TextMesh.transform.parent.localScale = new Vector3(feedbackSelectedAdaptiveUIDataEvent.newSize, feedbackSelectedAdaptiveUIDataEvent.newSize, feedbackSelectedAdaptiveUIDataEvent.newSize);
    }
    
    void OnUpdateData(UpdateAdaptiveUIDataEvent textPlayer)
    {
		m_selectedChoice = -1;


		if (textPlayer.choicePlayer.Count < 2 || textPlayer.choicePlayer.Count > 4)
        {
            Debug.LogError("Player choices count must be between 2 and 4");
            return;
        }

        if(m_pivot)
        Destroy(m_pivot.gameObject);

        m_numberChoice = textPlayer.choicePlayer.Count;
        
        m_choices = new Transform[m_numberChoice];
        m_correctChoice = textPlayer.correctChoice;

        m_mainCanvas = FindObjectOfType<Canvas>();
        m_pivot = (new GameObject()).transform;
        m_pivot.SetParent(m_mainCanvas.transform);
        
		m_pivot.position = Camera.main.WorldToScreenPoint(m_playerTransform.position + m_offset);
        m_pivot.localScale = Vector3.one; 

        // place the Four 
        float baseAngle = 90f;
        float decal = 180f / (m_numberChoice - 1);

        for (int i = 0; i < m_numberChoice; i++)
        {
            m_choices[i] = Instantiate(m_bublesPrefab, m_pivot).transform;
            UnityEngine.UI.Image imageUI = m_choices[i].GetComponent<UnityEngine.UI.Image>();
            
                targetOpacity = imageUI.color.a;
                Color temp = imageUI.color;
                temp.a = 0;
                imageUI.color = temp;
                imageUI.enabled = true;
            
            m_choices[i].SetParent(m_pivot.transform);
            m_choices[i].localPosition = Vector3.zero + Vector3.up * m_distance;
            if(m_numberChoice != 1)
            {
                m_choices[i].RotateAround(m_pivot.position, Vector3.forward, baseAngle - decal * (i));
            }

            m_choices[i].localRotation = Quaternion.identity;

            TMPro.TextMeshProUGUI UIText = m_choices[i].GetComponentInChildren<TMPro.TextMeshProUGUI>();
            UIText.text = textPlayer.choicePlayer[i];
            UIText.ForceMeshUpdate();
            
            m_choices[i].GetComponent<RectTransform>().sizeDelta = new Vector3(UIText.bounds.size.x*1.5f, UIText.bounds.size.y) + new Vector3(m_borderX+100f, m_borderY+ 100f);

        }

        float scaleFactor = m_choices[m_choices.Length - 1].GetComponentInParent<UnityEngine.UI.CanvasScaler>().scaleFactor;

        Bounds BoRight = m_choices[m_choices.Length - 1].GetComponentInChildren<TMPro.TextMeshProUGUI>().bounds;
        m_rightMinX = Screen.width - (m_distance + BoRight.extents.x * scaleFactor + m_borderX);
        m_rightMaxX = Screen.width - (BoRight.extents.x * scaleFactor + m_borderX);
        m_distanceForRightSide = m_rightMaxX - m_rightMinX;

        Bounds BoLeft = m_choices[0].GetComponentInChildren<TMPro.TextMeshProUGUI>().bounds;
        m_leftMinX = 0 + (m_distance + BoLeft.extents.x * scaleFactor + m_borderX);
        m_leftMaxX = 0 + (BoLeft.extents.x * scaleFactor + m_borderX);
        m_distanceForLeftSide = m_leftMaxX - m_leftMinX;

        m_extentsYMaximumOnLeftRightBubles = Mathf.Max(BoLeft.extents.y, BoRight.extents.y);

        if (m_numberChoice == 4)
        {
            Bounds middleLeft = m_choices[1].GetComponentInChildren<TMPro.TextMeshProUGUI>().bounds;
            Bounds middleRight = m_choices[2].GetComponentInChildren<TMPro.TextMeshProUGUI>().bounds;

            m_extentsYMaximumOnMiddleBubles = Mathf.Max(middleLeft.extents.y, middleRight.extents.y);
        }

        else if (m_numberChoice == 3)
        {
            Bounds middle = m_choices[1].GetComponentInChildren<TMPro.TextMeshProUGUI>().bounds;
            m_extentsYMaximumOnMiddleBubles = middle.extents.y;
        }

        else if (m_numberChoice == 2)
        {
            m_choices[0].GetComponentInChildren<TMPro.TextMeshProUGUI>().ForceMeshUpdate();
            Bounds middle = m_choices[0].GetComponentInChildren<TMPro.TextMeshProUGUI>().bounds;

            m_extentsYMaximumOnMiddleBubles = middle.extents.y;
        }

        m_extentsYForLeft = BoLeft.extents.y;
        m_extentsYForRight = BoRight.extents.y;


        enabled = true;
    }


    void Update()
    {
        m_pivot.position = Camera.main.WorldToScreenPoint(m_playerTransform.position + m_offset);
        float PosX = m_pivot.position.x;

        bool conditionForRight = PosX > m_rightMinX;
        bool conditionForLeft = PosX < m_leftMinX;

        // detect "right corder of the Screen"
        if (conditionForRight)
        {
            float valueForXBetween01 = (PosX - m_rightMinX) / m_distanceForRightSide;
            float rotationValue = Mathf.Lerp(0f, 90f, valueForXBetween01);

            if (m_numberChoice != 1)
            {
                m_pivot.rotation = Quaternion.Euler(0f, 0f, rotationValue);
            }

            KeepThemRight();

            updateYPivotPositionForUpSpecial(m_numberChoice - 2, m_numberChoice - 1, m_extentsYMaximumOnMiddleBubles, m_extentsYForRight);
        }
        else if (conditionForLeft)
        {
            float valueForXBetween01 = (PosX - m_leftMinX) / m_distanceForLeftSide;
            float rotationValue = Mathf.Lerp(0f, -90f, valueForXBetween01);

            if (m_numberChoice != 1)
            {
                m_pivot.rotation = Quaternion.Euler(0f, 0f, rotationValue);
            }

            KeepThemRight();

            updateYPivotPositionForUpSpecial(0, 1, m_extentsYForLeft, m_extentsYMaximumOnMiddleBubles);
        }

        // stop at borderRight
        if (PosX > (m_rightMaxX + m_borderX))
        {
            m_pivot.position = new Vector3((m_rightMaxX + m_borderX * 0.95f), m_pivot.position.y, m_pivot.position.z);
        }
        else if (PosX < (m_leftMaxX + m_borderX))
        {
            m_pivot.position = new Vector3((m_leftMaxX + m_borderX * 0.95f), m_pivot.position.y, m_pivot.position.z);
        }

        // reset
        if (!conditionForRight && !conditionForLeft)
        {
            if (m_numberChoice != 1)
            {
                updateYPivotPositionForUp(1, m_extentsYMaximumOnMiddleBubles);
            }
            else
            {
                updateYPivotPositionForUp(0, m_extentsYMaximumOnMiddleBubles);
            }

            resetToDefaultPosition();
        }

        if (m_numberChoice != 1)
        {
            updateYPivotPositionForDown(conditionForRight ? 0 : m_choices.Length - 1);
        }
        else
        {
            updateYPivotPositionForDown(0);
            updateYPivotPositionForUp(0, m_extentsYForLeft);
        }


        if(! m_noInput)
        {
            Vector2 stickPositionPure = (new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical")));

            // adapt the UI to the selection 
            Vector2 stickPosition = stickPositionPure.normalized * m_distance;

            if (stickPositionPure.magnitude > 0.2f)
            {

                float distance = 99999;
                int newSelected = noSelection;
                for (int i = 0; i < m_choices.Length; i++)
                {
                    Transform currentTransform = m_choices[i];
                    float currentDistance = Vector2.Distance(stickPosition, currentTransform.localPosition);
                    if (currentDistance < distance)
                    {
                        distance = currentDistance;
                        newSelected = i;
                    }
                }

                if (newSelected != m_selectedChoice)
                {
                    if (m_selectedChoice != noSelection)
                    {
                        m_choices[m_selectedChoice].DOScale(1f, delayTime);

                        m_textMeshOldSelected = m_choices[m_selectedChoice].GetComponentInChildren<TMPro.TMP_Text>();

                        // m_textMeshOldSelected.GetComponentInParent<UnityEngine.UI.Image>().enabled = false;

                        m_textMeshOldSelected.GetComponentInParent<UnityEngine.UI.Image>().DOFade(0f, 0.15f).SetEase(Ease.OutQuad);
                        
                        m_lerpForOld = 0f;
                        DOTween.To(() => m_lerpForCurrent, x =>
                        { m_lerpForOld = x; m_textMeshOldSelected.fontMaterial.Lerp(m_whenSelected, m_baseMaterial, m_lerpForOld); }, 1f, delayTime);

                        m_textMeshOldSelected.fontStyle = TMPro.FontStyles.Normal;
                    }

                    m_selectedChoice = newSelected;
                    m_choices[m_selectedChoice].DOScale(newSizeWhenSelected, delayTime);
                    m_textMeshCurrentSelected = m_choices[m_selectedChoice].GetComponentInChildren<TMPro.TMP_Text>();
                    m_lerpForCurrent = 0f;

                    m_textMeshCurrentSelected.fontStyle = TMPro.FontStyles.Bold;
                    // m_textMeshCurrentSelected.GetComponentInParent<UnityEngine.UI.Image>().enabled = true;
                    m_textMeshCurrentSelected.GetComponentInParent<UnityEngine.UI.Image>().DOFade(targetOpacity, 0.15f).SetEase(Ease.OutQuad);

                    m_textMeshCurrentSelected.fontMaterial = m_whenSelected;
                   // DOTween.To(() => m_lerpForCurrent, x =>
                   // { m_lerpForCurrent = x; m_textMeshCurrentSelected.fontMaterial.Lerp(m_baseMaterial, m_whenSelected, m_lerpForCurrent); }, 1f, delayTime);
                }
            }

            if (Input.GetButtonDown("Submit") && m_selectedChoice != noSelection)
            {
                m_noInput = true;
                
                for(int i = 0; i < m_choices.Length; i++)
                {
                    if(i != m_selectedChoice)
                    {
                        m_choices[i].DOScale(0f, delayTime);
                    }
                }
                UnityEngine.UI.Image imageUI = m_choices[m_selectedChoice].GetComponent<UnityEngine.UI.Image>();
                

                m_lerpForCurrent = 0f;
                if (m_correctChoice.Contains(m_selectedChoice))
                {
                    DOTween.To(() => m_lerpForCurrent, x =>
                    { m_lerpForCurrent = x; m_textMeshCurrentSelected.fontMaterial.Lerp(m_whenSelected, m_whenCorrect, m_lerpForCurrent); }, 1f, delayTime);

                    Vector3 worldPosofWord = m_demonCamera.ScreenToWorldPoint(m_choices[m_selectedChoice].position);
                    GameObject goodInst = Instantiate(m_goodParticle, worldPosofWord, Quaternion.identity);

                    var particleSystem = goodInst.GetComponent<ParticleSystem>();
                    var shape = particleSystem.shape;
                    shape.scale = new Vector3(m_textMeshCurrentSelected.bounds.size.x * 0.01f, 1f, m_textMeshCurrentSelected.bounds.size.y * 0.0075f);
                    // 90 sizeX = 7 particle
                    int nbParticle =  (int)(( m_textMeshCurrentSelected.bounds.size.x / 90f ) *7f );
                    var emmision = particleSystem.emission;
                    emmision.rateOverTime = nbParticle;

                    particleSystem.transform.LookAt(m_demonCamera.transform);

                    Destroy(goodInst, 5f);
                    imageUI.DOColor(blueOfPaul, delayTime);
                }
                else
                { 
                    DOTween.To(() => m_lerpForCurrent, x =>
                    { m_lerpForCurrent = x; m_textMeshCurrentSelected.fontMaterial.Lerp(m_whenSelected, m_whenWrong, m_lerpForCurrent); }, 1f, delayTime);

                    Vector3 worldPosofWord = m_demonCamera.ScreenToWorldPoint(m_choices[m_selectedChoice].position);
                    GameObject badInst = Instantiate(m_badParticle, worldPosofWord, Quaternion.identity);

                    
                    var particleSystem = badInst.GetComponent<ParticleSystem>();
                    /*
                    var shape = particleSystem.shape;
                    shape.scale = new Vector3(m_textMeshCurrentSelected.bounds.size.x * 0.01f, 1f, m_textMeshCurrentSelected.bounds.size.y * 0.0075f);
                    // 90 sizeX = 7 particle
                    int nbParticle = (int)((m_textMeshCurrentSelected.bounds.size.x / 90f) * 7f);
                    var emmision = particleSystem.emission;
                    emmision.rateOverTime = nbParticle;
                    */

                    particleSystem.transform.LookAt(m_demonCamera.transform);

                    Destroy(badInst, 5f);


                    imageUI.DOColor(redOfPaul, delayTime);
                }

                Invoke("sendEventOfSelection", delayTime);
            }
        }

    }

    private void sendEventOfSelection()
    {
        m_textMeshCurrentSelected.color = Color.white;
        Event<ChoiceIsSelectedAdaptiveUIDataEvent>.Broadcast(new ChoiceIsSelectedAdaptiveUIDataEvent(m_selectedChoice));
    }

    private void KeepThemRight()
    {
        foreach (Transform e in m_choices)
        {
            e.rotation = Quaternion.identity;
        }
    }

    void resetToDefaultPosition()
    {
        m_pivot.rotation = Quaternion.identity;
        KeepThemRight();
    }

    void updateYPivotPositionForDown(int index)
    {
        // pour le "bas" de l'écran
        float valueY = m_choices[index].position.y - m_extentsYMaximumOnLeftRightBubles - m_borderY;
        if (valueY < 0)
        {
            float PosY = m_pivot.position.y - valueY;
            m_pivot.position = new Vector3(m_pivot.position.x, PosY, m_pivot.position.z);
        }
    }

    public  void Reset(StopAdaptiveUIUIDataEvent e)
    {
        if (m_pivot)
            Destroy(m_pivot.gameObject);
        enabled = false;
        m_noInput = false;
    }

    void updateYPivotPositionForUp(int index, float extentsUsed)
    {
        // pour le "haut" de l'écran EN NEUTRE
        float valueY = m_choices[index].position.y + extentsUsed + m_borderY; 
        if (valueY > Screen.height)
        {
            float PosY = m_pivot.position.y - (valueY - Screen.height);
            m_pivot.position = new Vector3(m_pivot.position.x, PosY, m_pivot.position.z);
        }
    }

    void updateYPivotPositionForUpSpecial(int index0, int index1, float extentsUsed0, float extentsUsed1)
    {
        // pour le "haut" de l'écran DE GAUCHE A DROITE
        float choice0Y = m_choices[index0].position.y;
        float choice1Y = m_choices[index1].position.y;

        float maxValue = choice0Y + extentsUsed0 > choice1Y + extentsUsed1 ? choice0Y : choice1Y;
        
        float extentsUsed = maxValue == choice0Y ? extentsUsed0 : extentsUsed1;

        float valueY = maxValue + extentsUsed + m_borderY;
        if (valueY > Screen.height)
        {
            float PosY = m_pivot.position.y - (valueY - Screen.height);
            m_pivot.position = new Vector3(m_pivot.position.x, PosY, m_pivot.position.z);
        }

    }

}

