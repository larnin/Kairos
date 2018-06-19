using DG.Tweening;
using Sirenix.OdinInspector;
using Sirenix.Serialization;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;


public class DemonSpeakerExterialFeedback : MonoBehaviour
{
    [SerializeField] InformationForChoiceUI m_usedInformation = null;

    TextMeshPro m_textMeshPro;
    List<GameObject> m_onWordFeedbackInstance = new List<GameObject>();
    GameObject m_onWordEffect = null;


    void Awake()
    {
        m_textMeshPro = GetComponent<TextMeshPro>();
        m_onWordEffect = Instantiate(m_usedInformation.onWordParticleEffect);
        m_onWordEffect.SetActive(false);
    }

    public void placeEffectOnWord(int beginIndex, int lenght)
    {
        Bounds bound = getBoundsOfWord(beginIndex, lenght);
        m_onWordEffect.transform.position = transform.TransformPoint(bound.center);
        m_onWordEffect.transform.LookAt(Camera.main.transform);
        m_onWordEffect.gameObject.SetActive(true);
    }

    public void reset()
    {
        m_onWordEffect.gameObject.SetActive(false);
    }

    private Bounds getBoundsOfWord(int beginIndex, int lenght)
    {
        Bounds result = new Bounds();
        TMP_CharacterInfo[] characterInfo = m_textMeshPro.textInfo.characterInfo;

        int indexA = beginIndex;
        int indexB = indexA + lenght;

        Vector3 topLeft = characterInfo[indexA].topLeft;
        Vector3 bottomLeft = characterInfo[indexA].bottomLeft;
        Vector3 topRight = characterInfo[indexB].topRight;
        Vector3 bottomRight = characterInfo[indexB].bottomRight;

        result.center = (topLeft + bottomLeft + topRight + bottomRight) / 4f;
        result.extents = new Vector3((topRight.x - topLeft.x) / 2f + 0.1f, Mathf.Abs(topRight.y - bottomLeft.y) / 2f + 0.1f, (topRight.z - topLeft.z) / 2f);

        return result;
    }

    public void clear()
    {
        foreach (GameObject e in m_onWordFeedbackInstance)
        {
            Destroy(e);
        }
        m_onWordFeedbackInstance.Clear();
    }

    public void instansiateFeedbackOnSelectedWord(string newWord)
    {
        /*
       Bounds e = getBoundsOfWord(newWord);

        m_onWordFeedbackInstance.Add(Instantiate(m_usedInformation.onWordParticleEffect));
        m_onWordFeedbackInstance[m_onWordFeedbackInstance.Count - 1].transform.localScale = e.extents * 0.7f;
        m_onWordFeedbackInstance[m_onWordFeedbackInstance.Count - 1].transform.SetParent(transform);
        m_onWordFeedbackInstance[m_onWordFeedbackInstance.Count - 1].transform.localPosition = e.center;
        m_onWordFeedbackInstance[m_onWordFeedbackInstance.Count - 1].transform.Translate(Vector3.forward * -0.1f, Space.Self);
        */
    }
}

