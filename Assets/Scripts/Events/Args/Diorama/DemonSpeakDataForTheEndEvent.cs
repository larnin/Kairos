using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class DemonSpeakDataForTheEndEvent : EventArgs
{
    public DemonSpeakDataForTheEndEvent(List<string> _phrase, List<BaseTextEffectLogic> _textEffect, string _sceneName)
    {
        phraseToSay = _phrase;
        baseTextEffect = _textEffect;
        sceneName = _sceneName;
    }

    public List<string> phraseToSay = new List<string>();
    public List<BaseTextEffectLogic> baseTextEffect = new List<BaseTextEffectLogic>();
    public string sceneName = "";
}
