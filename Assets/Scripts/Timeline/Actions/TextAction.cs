using Sirenix.OdinInspector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class TextAction : BaseAction
{
    [Multiline]
    public string m_text;

    [HorizontalGroup("Font", Width = 20)] [HideLabel]
    public bool m_setFont;
    [HorizontalGroup("Font")] [EnableIf("m_setFont")]
    public TMP_FontAsset m_fontAsset;

    [HorizontalGroup("Material", Width = 20)][HideLabel]
    public bool m_setMaterial;
    [HorizontalGroup("Material")][EnableIf("m_setMaterial")]
    public Material m_material;


    [HorizontalGroup("Size", Width = 20)] [HideLabel]
    public bool m_setFontSize;
    [HorizontalGroup("Size")] [EnableIf("m_setFontSize")]
    public float m_fontSize;

    [HorizontalGroup("Effect", Width = 20)][HideLabel]
    public bool m_setEffect;
    [HorizontalGroup("Effect")][EnableIf("m_setEffect")]
    public BaseTextEffectLogic m_textEffect; 
    
    public override void trigger(GameObject obj)
    {
        var msg = obj.GetComponent<MessageBubbleLogic>();
        if(msg != null)
        {
            msg.setText(m_text);
            if (m_setFont)
                msg.setFont(m_fontAsset);
            if (m_setFontSize)
                msg.setFontSize(m_fontSize);
            if (m_setMaterial)
                msg.setMaterial(m_material);
            //msg.setBubbleSize(); 
            if (m_setEffect)
            {
                msg.setTextEffect(m_textEffect);
            }
            else msg.setTextEffect(null);
        }
        else
        {
            var tmp = obj.GetComponent<TextMeshPro>();
            if (tmp != null)
            {
                tmp.text = m_text;
                if (m_setFont)
                    tmp.font = m_fontAsset;
                if (m_setFontSize)
                    tmp.fontSize = m_fontSize;
            }
            else
            {
                var tmpGUI = obj.GetComponent<TextMeshProUGUI>();
                if (tmpGUI != null)
                    tmpGUI.text = m_text;
                else Debug.LogError("Can't find a TextMeshPro or a TextMeshProUGUI or an UI.Text component on " + obj.name);
            }
        }
    }
}
