using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using Sirenix.OdinInspector;


public class PlayerChoice
{
    public string Word = " ";
    public bool isCorrect = false;
    public List<DemonPhrase> DemonPhraseSayAfter = new List<DemonPhrase>();
}

public class DemonPhrase
{
    [Multiline]
    public string basePhrase = " ";
    [HorizontalGroup]
    public bool hasChoice = false;
    [HorizontalGroup]
    public bool skipable = false;
    public bool hasDifferentEffect = false;

	[ShowIf("hasDifferentEffect")]
	public BaseTextEffectLogic m_textEffectForDemonSpeak = null;

	public BaseDioramaAction dioramaAction = null;

    [ShowIf("hasChoice")]
    public string baseWord;

    [ShowIf("hasChoice")]
    public string clue = "";

    [ShowIf("hasChoice")]
    public List<PlayerChoice> playerChoices = new List<PlayerChoice>();
    
}


