using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

public class UpdateAdaptiveUIDataEvent : EventArgs
{
    public UpdateAdaptiveUIDataEvent(List<string> _choicePlayer, List<int> _correctChoice)
    {
        choicePlayer = _choicePlayer;
        correctChoice = _correctChoice;
    }

    public List<string> choicePlayer;
    public List<int> correctChoice;
}