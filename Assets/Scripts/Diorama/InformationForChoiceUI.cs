using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class InformationForChoiceUI : ScriptableObject
{
    public bool ChangedWordBold;
    
    public TMPro.TMP_FontAsset FontSelectableWordDefault;
    public Material MaterialSelectableWordDefault;

    public TMPro.TMP_FontAsset FontSelectableWordCorrect;
    public Material MaterialSelectableWordCorrect;

    public TMPro.TMP_FontAsset FontSelectableWordWrong;
    public Material MaterialSelectableWordWrong;
    
    public float ChoiceBubbleNewSize = 1.25f;
    public float timetoReadPerCharacter = 0.02f;
    public float secondToWaitWhenPhraseIsVisible = 1.5f;
    public float baseTimePauseDelay = 0.1f;

    public GameObject onWordParticleEffect;

    // PLACEHOLDERS
    public GameObject PH_SelectedGameObject = null;
}

