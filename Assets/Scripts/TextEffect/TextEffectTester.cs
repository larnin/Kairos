using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using DG.Tweening;

public class TextEffectTester : MonoBehaviour {

    [SerializeField] BaseTextEffectLogic m_baseTextEffectLogic;
    private TMP_Text m_TextComponent;
    const float fadeDelay = 1f;
    
    void Awake()
    {
        m_TextComponent = GetComponent<TMP_Text>();
    }
    
    void Start ()
    {
        StartCoroutine(enumerator());
    }

    void LateUpdate()
    {
        m_TextComponent.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);
        m_TextComponent.UpdateVertexData(TMP_VertexDataUpdateFlags.Vertices);
    }

    IEnumerator enumerator()
    {
        while (true)
        {
            m_baseTextEffectLogic.initialize(BaseTextEffectLogic.createLetters(m_TextComponent), m_TextComponent.transform);
            m_TextComponent.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);
            m_TextComponent.UpdateVertexData(TMP_VertexDataUpdateFlags.Vertices);
            yield return null;
            yield return m_baseTextEffectLogic.run();
            yield return new WaitForSeconds(fadeDelay);
        }
    }
}
