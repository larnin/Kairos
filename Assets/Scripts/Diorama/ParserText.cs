using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

class ParserText
{
    const string TEXT_EFFECT_EMPLACEMENT = "DataForTextEffect/";

    public class PauseEmplacement
    {
        public PauseEmplacement(int _index, float _duration)
        {
            index = _index;
            duration = _duration;
        }
        public int index;
        public float duration;
    }
    public class KeywordEmplacement
    {
        public KeywordEmplacement(int _index, int _lenght)
        {
            index = _index;
            lenght = _lenght;
        }
        public int index;
        public int lenght;
    }

    public class SubTextEffectEmplacement
    {
        public SubTextEffectEmplacement(int _index, int _lenght, BaseTextEffectLogic _textEffect)
        {
            index = _index;
            lenght = _lenght;
            textEffect = GameObject.Instantiate(_textEffect);
        }
        public int index;
        public int lenght;
        public BaseTextEffectLogic textEffect;
    } 

    [NonSerialized] public TMPro.TextMeshPro m_textMeshPro;
    [NonSerialized] public BaseTextEffectLogic m_defaultTextEffect;
    
    [NonSerialized] public List<PauseEmplacement> m_pauseEmplacement = new List<PauseEmplacement>();
    [NonSerialized] public List<KeywordEmplacement> m_keyWordDetectionLengthEmplacement = new List<KeywordEmplacement>();
    [NonSerialized] public List<SubTextEffectEmplacement> m_subTextEffectEmplacement = new List<SubTextEffectEmplacement>();

    string m_parsedTextPro = "";
    string m_pureText = "";
    
    public string parse(DemonPhrase demonPhrase = null)
    {
        m_pauseEmplacement.Clear();
        m_subTextEffectEmplacement.Clear();

        m_subTextEffectEmplacement.Add(new SubTextEffectEmplacement(0, m_parsedTextPro.Length, m_defaultTextEffect));

        m_parsedTextPro = m_textMeshPro.GetParsedText();
        m_pureText = m_textMeshPro.text;

        int firstTagIndex = 0;
        int lastTagIndex = firstTagIndex;

        while (true)
        {
            firstTagIndex = m_parsedTextPro.IndexOf('{');
            lastTagIndex = m_parsedTextPro.IndexOf('}');
            
            if ((firstTagIndex == -1) || (lastTagIndex == -1))
            {
                break;
            }

            if(firstTagIndex > lastTagIndex)
            {
                Debug.LogError("PARSING ERROR : tag not correct");
                break;
            }
            // Ici on trouve ce que c'est ! 
            string InTagText = m_parsedTextPro.Substring(firstTagIndex + 1, lastTagIndex - (firstTagIndex + 1));

            if (demonPhrase != null && InTagText.Length == 1 && InTagText == "0")
                parseKeyWord(demonPhrase.baseWord);
            else if (InTagText.Length > 1 && InTagText[0] == 'd') // d for delay
                parseDelay(InTagText, firstTagIndex, lastTagIndex);
            else if (InTagText.Length > 3 && InTagText.StartsWith("te_"))
            {
                if (firstTagIndex == 0)
                    m_subTextEffectEmplacement.Clear();

                parseForBeginTextEffect(InTagText, firstTagIndex, lastTagIndex);
            }
            else if (InTagText.Length == 3 && InTagText.StartsWith("/te"))
                parseForEndTextEffect(InTagText, firstTagIndex, lastTagIndex);
            else
            {
                Debug.LogError("Parse error a tag is not correct : " + InTagText);
            }
        }
        // ajoutez ici vos clean de tag pour le pure : 
        cleanAllTagInPure();

        int lenghtOfLast = m_parsedTextPro.Length - m_subTextEffectEmplacement[m_subTextEffectEmplacement.Count - 1].index;
        m_subTextEffectEmplacement[m_subTextEffectEmplacement.Count - 1].lenght = lenghtOfLast;

        // veryfing data of textEffect

        //Debug.Log("#########################");
        //foreach (SubTextEffectEmplacement e in m_subTextEffectEmplacement)
        //{
        //    Debug.Log(e.index + "  " + (e.index + e.lenght) + " " + e.textEffect.name);
        //}
        //Debug.Log("#########################");

        m_textMeshPro.text = m_pureText;
        m_textMeshPro.ForceMeshUpdate();
        return m_parsedTextPro;
    }

    // ###################################################################
    // parsing per categories : 
    private void parseDelay(string textInsideTag, int firstTagIndex, int lastTagIndex)
    {
        float delayValue;
        float.TryParse(textInsideTag.Substring(1), out delayValue);
        m_pauseEmplacement.Add(new PauseEmplacement(firstTagIndex, delayValue));
        m_parsedTextPro = m_parsedTextPro.Remove(firstTagIndex, lastTagIndex - firstTagIndex + 1);
    }

    private void parseKeyWord(string wordToPutIn)
    {
        m_parsedTextPro = m_parsedTextPro.Replace("{0}", wordToPutIn);
        int firstNewWord = m_parsedTextPro.IndexOf(wordToPutIn);
        int lenght = wordToPutIn.Length;
        m_keyWordDetectionLengthEmplacement.Clear();
        m_keyWordDetectionLengthEmplacement.Add(new KeywordEmplacement(firstNewWord, lenght));
    }

    private void parseForBeginTextEffect(string textInsideTag, int firstTagIndex, int lastTagIndex)
    {
        string effectName = textInsideTag.Substring(3);
        BaseTextEffectLogic baseTextEffect = Resources.Load(TEXT_EFFECT_EMPLACEMENT + effectName) as BaseTextEffectLogic;

        if (baseTextEffect == null)
        {
            Debug.LogError("ERROR : the effect name is not correct : " + effectName);
        }

        if (firstTagIndex == 0)
        {
            m_subTextEffectEmplacement.Clear();
        }
        else
        {
            m_subTextEffectEmplacement[m_subTextEffectEmplacement.Count - 1].lenght = firstTagIndex - m_subTextEffectEmplacement[m_subTextEffectEmplacement.Count - 1].index;
        }

        m_subTextEffectEmplacement.Add(new SubTextEffectEmplacement(firstTagIndex, m_parsedTextPro.Length, baseTextEffect));
        m_parsedTextPro = m_parsedTextPro.Remove(firstTagIndex, lastTagIndex - firstTagIndex + 1);
    }

    private void parseForEndTextEffect(string textInsideTag, int firstTagIndex, int lastTagIndex)
    {
        m_subTextEffectEmplacement[m_subTextEffectEmplacement.Count - 1].lenght = lastTagIndex - m_subTextEffectEmplacement[m_subTextEffectEmplacement.Count - 1].index - 2/*ici on a la taille du mot*/ - 1 /*on retire l'espace*/;
        m_parsedTextPro = m_parsedTextPro.Remove(firstTagIndex, lastTagIndex - firstTagIndex + 1);

        m_subTextEffectEmplacement.Add(new SubTextEffectEmplacement(firstTagIndex + 1, 500, m_defaultTextEffect));
    }


    // ###################################################################
    // cleaning per categories : 
    
    private void cleanAllTagInPure()
    {
        int firstTagIndex = m_pureText.IndexOf('{');
        int lastTagIndex = m_pureText.IndexOf('}');
        int beginIndex = 0;
        while (firstTagIndex != -1 && lastTagIndex != -1)
        {
            if ((firstTagIndex == -1) || (lastTagIndex == -1))
            {
                return ;
            }

            if (m_pureText[firstTagIndex + 1] != '0')
            {
                m_pureText = m_pureText.Remove(firstTagIndex, lastTagIndex - firstTagIndex +1);
            }
            else
            {
                beginIndex = (lastTagIndex + 1);
                if(beginIndex >= m_pureText.Length)
                {
                    break;
                }
            }
                
            
            firstTagIndex = m_pureText.IndexOf('{', beginIndex);
            lastTagIndex = m_pureText.IndexOf('}', beginIndex);
            beginIndex = firstTagIndex;
        }
    }
}