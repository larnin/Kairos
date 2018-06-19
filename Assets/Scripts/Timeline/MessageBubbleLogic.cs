using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using TMPro;
using System.Collections;
using DG.Tweening;

public class MessageBubbleLogic : MonoBehaviour
{
    public float m_heightOffset = 0.5f;
	[SerializeField] GameObject m_assignedBubble;
	[SerializeField] GameObject m_assignedQueue;
	[SerializeField] public GameObject m_assignedSpeaker;
    [SerializeField] float m_borderSize = 0.4f;
    [SerializeField] Vector2 m_offset;


    TextMeshPro m_text;
    bool m_fastForwardRunning = false;

    SubscriberList m_subscriberList = new SubscriberList();

    ParserText m_parserText = new ParserText();
    Coroutine m_TextEffectRunning = null;
    BaseTextEffectLogic m_instanceEffect;

    private void Awake()
    {
        m_text = transform.Find("Text").GetComponent<TextMeshPro>();
        m_text.text = "";
        m_text.GetComponent<Renderer>().material.renderQueue = 3010;

        m_subscriberList.Add(new Event<TimelineFastForwardEvent>.Subscriber(onFastForward));
        m_subscriberList.Subscribe();
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    public void setText(string text) //1
    {
        stopEffect();

        m_text.text = text;
        updateBubble();
    }

    public void setFont(TMP_FontAsset font) //2
    {
        stopEffect();

        m_text.font = font;
        updateBubble();
    }

    public void setFontSize(float size) //3
    {
        stopEffect();

        m_text.fontSize = size;
        updateBubble();
    }

    public void setMaterial(Material material) //4
    {
        stopEffect();

        m_text.fontSharedMaterial = material;
        updateBubble();
    }

    public void setTextEffect(BaseTextEffectLogic effect) //5
    {
        stopEffect();
        
        if (effect == null) effect = Resources.Load("DataForTextEffect/normal") as BaseTextEffectLogic;
        m_instanceEffect = Instantiate(effect);

        m_parserText = new ParserText();
        m_parserText.m_textMeshPro = m_text;
        m_parserText.m_defaultTextEffect = m_instanceEffect;
        m_parserText.parse();

        updateBubble();

        if (m_fastForwardRunning)
            return;
        
        int indexDelay = 0;
        foreach (ParserText.SubTextEffectEmplacement e in m_parserText.m_subTextEffectEmplacement)
        {
            e.textEffect.setAction(
                (i) =>
                {
                    if (m_parserText.m_pauseEmplacement.Count > indexDelay
                && (m_parserText.m_pauseEmplacement[indexDelay].index == i))
                    {
                        indexDelay++;
                        return m_parserText.m_pauseEmplacement[indexDelay - 1].duration;
                    }
                    else
                    {
                        return 0;
                    }
                });

            e.textEffect.initialize(BaseTextEffectLogic.createLetters(m_text, e.index, e.lenght), m_text.transform);
        }
        m_text.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);
        m_text.UpdateVertexData(TMP_VertexDataUpdateFlags.Vertices);

        m_TextEffectRunning = StartCoroutine(readText());
    }

    void onFastForward(TimelineFastForwardEvent e)
    {
        m_fastForwardRunning = e.started;
        if(m_fastForwardRunning)
            stopEffect();
    }

    void updateBubble()
    {
        m_text.ForceMeshUpdate();

        var bounds = m_text.textBounds;

        var sprite = m_assignedBubble.GetComponent<SpriteRenderer>();
        sprite.size = new Vector2(bounds.size.x + 2 * m_borderSize, bounds.size.y + 2 * m_borderSize);
        
        m_text.transform.localPosition = -bounds.center;

        m_assignedQueue.SetActive(false);
        DOVirtual.DelayedCall(0.01f, () =>
        {
            m_assignedQueue.SetActive(true);
            if (m_assignedSpeaker == null)
            {
                m_assignedQueue.transform.localPosition = new Vector3(0, -bounds.size.y / 2 - m_borderSize, 0);
            }
            else
            {

                Vector3 target = m_assignedBubble.transform.InverseTransformPoint(m_assignedSpeaker.transform.position);
                var comp = m_assignedSpeaker.GetComponent<ShadowLerpMoveLogic>();
                if (comp != null)
                    target = comp.getTargetPosition();

                m_assignedQueue.transform.localPosition = Vector3.zero;
                var rot = Mathf.Atan2(target.y - m_offset.y, target.x - m_offset.x);
                m_assignedQueue.transform.localRotation = Quaternion.Euler(0, 0, rot * Mathf.Rad2Deg + 90);

                var s = new Vector2(m_borderSize + bounds.size.x / 2, m_borderSize + bounds.size.y / 2);

                var dir = new Vector2(Mathf.Cos(rot), Mathf.Sin(rot));

                var dir2 = dir * s.x / Mathf.Abs(dir.x);
                if (Mathf.Abs(dir2.y) > s.y)
                    dir2 = dir * s.y / Mathf.Abs(dir.y);
                dir2 += m_offset;
                dir2.x = Mathf.Clamp(dir2.x, -s.x, s.x);
                dir2.y = Mathf.Clamp(dir2.y, -s.y, s.y);

                m_assignedQueue.transform.localPosition = dir2;
            }
        });
    }

    void stopEffect()
    {
        if(m_TextEffectRunning != null)
            StopCoroutine(m_TextEffectRunning);
        if (m_parserText != null)
        {
            foreach (ParserText.SubTextEffectEmplacement e in m_parserText.m_subTextEffectEmplacement)
            {
                if (e != null && e.textEffect != null)
                {
                    e.textEffect.reset();
                }
            }
            m_parserText = null;
        }
    }

    IEnumerator readText()
    {
        
        foreach (ParserText.SubTextEffectEmplacement e in m_parserText.m_subTextEffectEmplacement)
        {
            yield return e.textEffect.run();
        }
    }

    public void LateUpdate()
    {
        m_text.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);
        m_text.UpdateVertexData(TMP_VertexDataUpdateFlags.Vertices);
    }
}

