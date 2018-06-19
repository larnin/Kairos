using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class DemonSpeakDataEvent : EventArgs
{
    public DemonSpeakDataEvent(DemonPhrase _demonPhrase, BaseTextEffectLogic _textEffect)
    {
        demonPhrase = _demonPhrase;
        textEffect = _textEffect;
    }
    
    public DemonPhrase demonPhrase;
    public BaseTextEffectLogic textEffect;
}