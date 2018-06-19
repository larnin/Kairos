using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


public class ShowTutorialTextEvent : EventArgs
{
    public ShowTutorialTextEvent(float _fade, string _text)
    {
        fade = _fade;
        text = _text;
        noStop = true;
    }

    public ShowTutorialTextEvent(float _fade, float _time, string _text)
    {
        fade = _fade;
        time = _time;
        text = _text;
        noStop = false;
    }

    public float fade;
    public float time;
    public string text;
    public bool noStop;
}