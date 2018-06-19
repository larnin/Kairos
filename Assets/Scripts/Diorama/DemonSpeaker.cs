using DG.Tweening;
using Sirenix.OdinInspector;
using Sirenix.Serialization;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class DemonSpeaker : MonoBehaviour
{
	const float fastforwardSpeed = 4f;
	const float findInputSpeed = 15f;

	enum WordSelectedVisual
	{
		Default,
		Correct,
		Wrong
	};

	[SerializeField] InformationForChoiceUI m_usedInformation = null;
	[SerializeField] GameObject m_UIPivot;
	[SerializeField] AudioClip GoodAnswerFeedback;
	[SerializeField] AudioClip BadAnsweFeedback;

	[SerializeField] float m_demonvoiceVolume = 0.5f;
	[SerializeField] AudioSource demonVoice;

	DemonPhrase m_demonPhrase;
	BaseTextEffectLogic m_textEffect;
	TextMeshPro m_textMeshPro;
	//DemonSpeakerExterialFeedback m_demonSpeakerExterialFeedback;

	ParserText m_parserText = new ParserText();

	bool m_canDetectInputWhenWord = false;
	bool m_textAppearing = false;
	bool m_demonIsSpeaking = false;
	bool m_detectedInputOnWord = false;
	bool m_end = false;
	bool m_jump = false;

	int m_currentKeyWordDetected = 0;
	int m_indexDelay = 0;
	int m_answerNumber = 0;

	float m_localTimeScale = 1f;

	SubscriberList m_subscriberList = new SubscriberList();

	Coroutine m_textCoroutine;

	void Awake()
	{
		gameObject.SetActive(false);
		m_textMeshPro = GetComponent<TextMeshPro>();
		// m_demonSpeakerExterialFeedback = GetComponent<DemonSpeakerExterialFeedback>();
		m_subscriberList.Add(new Event<DemonSpeakDataEvent>.Subscriber(makeTheDemonSpeak));
		m_subscriberList.Add(new Event<ChoiceIsSelectedAdaptiveUIDataEvent>.Subscriber(selectAnswer));
		//m_subscriberList.Add(new Event<DemonSpeakDataForTheEndEvent>.Subscriber(makeTheDemonSpeakEND));
		m_UIPivot.SetActive(false);

		m_parserText.m_defaultTextEffect = m_textEffect;

	}

	void OnEnable()
	{
		m_subscriberList.Subscribe();
		m_textMeshPro.text = "";
		m_textMeshPro.ForceMeshUpdate();
	}

	void OnDisable()
	{
		m_subscriberList.Unsubscribe();
	}

	void OnDestroy()
	{
		m_subscriberList.Unsubscribe();
	}

	void makeTheDemonSpeak(DemonSpeakDataEvent demonSpeakDataEvent)
	{
		StopAllCoroutines();
		// var textInfo = m_textMeshPro.textInfo;
		// textInfo.Clear();

		if (demonSpeakDataEvent == null)
		{
			foreach (ParserText.SubTextEffectEmplacement e in m_parserText.m_subTextEffectEmplacement)
			{
				e.textEffect.reset();
			}
			DemonStopVoice();
			m_UIPivot.SetActive(false);
			m_textMeshPro.text = "";
			m_textMeshPro.ForceMeshUpdate();
			m_textMeshPro.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);
			m_textMeshPro.UpdateVertexData(TMP_VertexDataUpdateFlags.Vertices);
			return;
		}
		else
		{
			m_UIPivot.SetActive(true);
		}

		gameObject.SetActive(true);
		m_demonPhrase = demonSpeakDataEvent.demonPhrase;
		m_textEffect = demonSpeakDataEvent.textEffect;

		m_parserText.m_textMeshPro = m_textMeshPro;
		m_parserText.m_defaultTextEffect = m_textEffect;

		bool hasChoice = m_demonPhrase.hasChoice;
		m_detectedInputOnWord = false;

		m_textMeshPro.text = m_demonPhrase.basePhrase;
		m_textMeshPro.ForceMeshUpdate();

		m_parserText.parse(m_demonPhrase);

		if (hasChoice)
		{
			Event<StartDemonTextWithChoiceEvent>.Broadcast(new StartDemonTextWithChoiceEvent());
			ReplaceWordInDemonText(m_textMeshPro.text, m_demonPhrase.baseWord, "{0}", null);
		}

		m_currentKeyWordDetected = 0;
		m_indexDelay = 0;
		m_canDetectInputWhenWord = false;

		//m_textMeshPro.ForceMeshUpdate();
		foreach (ParserText.SubTextEffectEmplacement e in m_parserText.m_subTextEffectEmplacement)
		{
			e.textEffect.setAction(
			 (i) => {

				 if (hasChoice)
				 {
					 bool oldValue = m_canDetectInputWhenWord;
					 m_canDetectInputWhenWord = m_parserText.m_keyWordDetectionLengthEmplacement.Count != m_currentKeyWordDetected
					 && i > m_parserText.m_keyWordDetectionLengthEmplacement[m_currentKeyWordDetected].index;

					 //if (oldValue == false && m_canDetectInputWhenWord == true)
					 //{
					 //     m_demonSpeakerExterialFeedback.placeEffectOnWord(m_parserText.m_keyWordDetectionLengthEmplacement[m_currentKeyWordDetected].index,
					 //        m_parserText.m_keyWordDetectionLengthEmplacement[m_currentKeyWordDetected].lenght);
					 //}
				 }

				 if (m_parserText.m_pauseEmplacement.Count > m_indexDelay
				 && m_parserText.m_pauseEmplacement[m_indexDelay].index == i)
				 {
					 m_indexDelay++;
					 return m_parserText.m_pauseEmplacement[m_indexDelay - 1].duration;
				 }
				 else
				 {
					 return 0;
				 }
			 });

			e.textEffect.initialize(BaseTextEffectLogic.createLetters(m_textMeshPro, e.index, e.lenght), m_textMeshPro.transform);
		}

		m_textMeshPro.UpdateVertexData(TMP_VertexDataUpdateFlags.Colors32);
		m_textMeshPro.UpdateVertexData(TMP_VertexDataUpdateFlags.Vertices);
		// launch the things ! 
		m_textCoroutine = StartCoroutine(launchPhrase());
	}

	void selectAnswer(ChoiceIsSelectedAdaptiveUIDataEvent choiceSelected)
	{
		Event<GiveClueDataEvent>.Broadcast(new GiveClueDataEvent(""));

		m_answerNumber = choiceSelected.index;
		m_textAppearing = false;

		m_textMeshPro.text = m_demonPhrase.basePhrase;
		m_textMeshPro.ForceMeshUpdate();

		m_parserText.parse(m_demonPhrase);

		ReplaceWordInDemonText(m_textMeshPro.text,
					   m_demonPhrase.playerChoices[m_answerNumber].Word,
					   "{0}",
					   m_demonPhrase.playerChoices[m_answerNumber].isCorrect ? GoodAnswerFeedback : BadAnsweFeedback,
					   m_demonPhrase.playerChoices[m_answerNumber].isCorrect ? WordSelectedVisual.Correct : WordSelectedVisual.Wrong);
		Invoke("selectAnswerFeedbackDone", 1f);
	}

	void selectAnswerFeedbackDone()
	{
		foreach (ParserText.SubTextEffectEmplacement e in m_parserText.m_subTextEffectEmplacement)
		{
			e.textEffect.reset();
		}


		m_demonIsSpeaking = false;

		Event<StopAdaptiveUIUIDataEvent>.Broadcast(null);
		Event<DemonDoneTalkingDataEvent>.Broadcast(new DemonDoneTalkingDataEvent(m_answerNumber));
		//m_demonSpeakerExterialFeedback.reset();
	}

	private void Update()
	{
		if (m_textAppearing && !m_end)
		{
			if (Input.GetButton("FastForwardText"))
			{
				if (m_demonPhrase.skipable)
					breakText();
				else
				{
					if (m_localTimeScale != fastforwardSpeed)
					{
						m_localTimeScale = fastforwardSpeed;
						UpdateTimeScale();
					}
				}
			}
			else if (m_localTimeScale != 1f && !m_detectedInputOnWord)
			{
				m_localTimeScale = 1f;
				UpdateTimeScale();
			}
		}

		if (m_canDetectInputWhenWord)
		{
			m_detectedInputOnWord = detectInput(m_demonPhrase.baseWord, m_detectedInputOnWord);
		}
	}

	private void UpdateTimeScale()
	{
		foreach (ParserText.SubTextEffectEmplacement e in m_parserText.m_subTextEffectEmplacement)
		{
			if (e != null)
			{
				e.textEffect.setLocalTimeScale(m_localTimeScale);
			}
		}
	}

	void breakText()
	{
		if (m_textCoroutine != null)
		{
			StopCoroutine(m_textCoroutine);
			selectAnswerFeedbackDone();
		}
	}

	void LateUpdate()
	{
		if (m_demonIsSpeaking)
		{
			m_textMeshPro.UpdateVertexData(TMPro.TMP_VertexDataUpdateFlags.Colors32);
			m_textMeshPro.UpdateVertexData(TMPro.TMP_VertexDataUpdateFlags.Vertices);
		}
	}

	IEnumerator launchPhrase()
	{
		m_answerNumber = -1;
		//Si tu veux que le démon fasse du son à chaque phrase, met ici GetComponent<AudioSource>().Play();
		m_demonIsSpeaking = true;
		m_textAppearing = true;
		//print("go inside");
		// print(m_parserText.m_subTextEffectEmplacement.Count);

		foreach (ParserText.SubTextEffectEmplacement e in m_parserText.m_subTextEffectEmplacement)
		{
			//  print(m_parserText.m_subTextEffectEmplacement.Count);
			//print("beginRun");
			yield return e.textEffect.run(true);
			//print("endRun");
			// print(m_parserText.m_subTextEffectEmplacement.Count);
		}

		//et ici GetComponent<AudioSource>().Stop();
		m_textAppearing = false;

		m_canDetectInputWhenWord = false;

		if (m_demonPhrase.hasChoice)
		{
			m_canDetectInputWhenWord = !m_detectedInputOnWord;
		}
		m_localTimeScale = 1f;
		UpdateTimeScale();

		while (true)
		{
			if (Input.GetButtonDown("FastForwardText") || m_detectedInputOnWord)
			{
				break;
			}
			yield return null;
		}
		// aprés que toute la phrase est affiché ont attend un peu
		/*	if (!m_demonPhrase.hasChoice || m_detectedInputOnWord)
        {
			float time = 0f;
            while (time < m_usedInformation.secondToWaitWhenPhraseIsVisible 
                && !m_detectedInputOnWord)
            {
                time += Time.deltaTime * ( (Input.GetButton("FastForwardText") ? fastforwardSpeed : 1f));
                yield return null;
            }
			
        }*/


		m_canDetectInputWhenWord = false;
		m_localTimeScale = 1f;
		UpdateTimeScale();

		if (!m_detectedInputOnWord)
		{
			selectAnswerFeedbackDone();
			/*m_demonIsSpeaking = false;
            Event<DemonDoneTalkingDataEvent>.Broadcast(new DemonDoneTalkingDataEvent(m_answerNumber));
            m_demonSpeakerExterialFeedback.reset();*/
		}
		else
		{
			launchChoice();
		}
	}

	private void launchChoice()
	{
		//m_demonSpeakerExterialFeedback.clear();

		List<string> playerWords = new List<string>();
		foreach (PlayerChoice e in m_demonPhrase.playerChoices)
		{
			playerWords.Add(e.Word);
		}
		List<int> correctChoice = new List<int>();
		for (int i = 0; i < m_demonPhrase.playerChoices.Count; i++)
		{
			if (m_demonPhrase.playerChoices[i].isCorrect)
			{
				correctChoice.Add(i);
			}
		}

		Event<GiveClueDataEvent>.Broadcast(new GiveClueDataEvent(m_demonPhrase.clue));
		Event<UpdateAdaptiveUIDataEvent>.Broadcast(new UpdateAdaptiveUIDataEvent(playerWords, correctChoice));
		foreach (ParserText.SubTextEffectEmplacement e in m_parserText.m_subTextEffectEmplacement)
		{
			e.textEffect.reset();
		}
	}

	private void ReplaceWordInDemonText(string textForDemon, string newWord, string tagToChange, AudioClip FeedbackSound, WordSelectedVisual wordSelectedVisual = WordSelectedVisual.Default)
	{
		//string BoldBegin = m_usedInformation.ChangedWordBold ? "<b>" : "";
		//string BoldEnd = m_usedInformation.ChangedWordBold ? "</b>" : "";

		TMPro.TMP_FontAsset FontSelectableWord;
		Material MaterialSelectableWord;
		GetComponent<AudioSource>().clip = FeedbackSound;
		GetComponent<AudioSource>().Play();


		switch (wordSelectedVisual)
		{
			case WordSelectedVisual.Default:
				FontSelectableWord = m_usedInformation.FontSelectableWordDefault;
				MaterialSelectableWord = m_usedInformation.MaterialSelectableWordDefault;
				break;
			case WordSelectedVisual.Correct:
				FontSelectableWord = m_usedInformation.FontSelectableWordCorrect;
				MaterialSelectableWord = m_usedInformation.MaterialSelectableWordCorrect;

				break;
			case WordSelectedVisual.Wrong:
				FontSelectableWord = m_usedInformation.FontSelectableWordWrong;
				MaterialSelectableWord = m_usedInformation.MaterialSelectableWordWrong;
				break;
			default:
				FontSelectableWord = null;
				MaterialSelectableWord = null;
				Debug.LogError("something bad happen !!!! WordSelectedVisual not correct value");
				break;
		}


		string MaterialBegin = "<font=\"" + FontSelectableWord.name + "\" material=\"" +
			MaterialSelectableWord.name + "\">";
		string MaterialEnd = "</font>";


		string newTest = /*BoldBegin + */MaterialBegin + newWord + MaterialEnd/* + BoldEnd*/;
		m_textMeshPro.text = textForDemon.Replace(tagToChange, newTest);
		m_textMeshPro.ForceMeshUpdate();
	}


	private bool detectInput(string newWord, bool detectedInputOnWord)
	{
		if (Input.GetButtonDown("DetectWord") && !detectedInputOnWord)
		{
			// m_demonSpeakerExterialFeedback.instansiateFeedbackOnSelectedWord(newWord);
			m_localTimeScale = findInputSpeed;
			UpdateTimeScale();

			detectedInputOnWord = true;
		}

		return detectedInputOnWord;
	}

	public void makeDemonSpeak()
	{
		demonVoice.volume = m_demonvoiceVolume;
		demonVoice.loop = true;
		demonVoice.Play();
	}


	void DemonStopVoice()
	{
		DOTween.To(() => demonVoice.volume, x => demonVoice.volume = x, 0, 1f);
		demonVoice.loop = false;
	}

}
	