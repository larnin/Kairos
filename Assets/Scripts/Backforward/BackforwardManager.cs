using UnityEngine;
using System.Collections;
using System;
using System.Collections.Generic;
using Sirenix.OdinInspector;
using DG.Tweening;
using Sirenix.Serialization;

public class BackforwardManager : SerializedMonoBehaviour
{
    [SerializeField] Light folletLight1;
    [SerializeField] Light folletLight2;

    float lightIntensity1;
    float lightIntensity2;


    [Serializable]
    class Chunk
    {
        [HideLabel, HorizontalGroup("d", Width = 20)]
        public bool execDiscution = true;
        [HorizontalGroup("d"), LabelWidth(100), EnableIf("execDiscution")]
        public BackforwardDiscutionLogic discution;
        [HideLabel, HorizontalGroup("m", Width = 20)]
        public bool execMasks = true;
        [HorizontalGroup("m"), LabelWidth(100), EnableIf("execMasks")]
        public MaskSelectionLogic masks;
        [HideLabel, HorizontalGroup("s", Width = 20)]
        public bool execScene = true;
        [HorizontalGroup("s"), LabelWidth(100), EnableIf("execScene")]
        public BackforwardTimelineLogic scene;
        //todo add scene;
    }

    [SerializeField] List<Chunk> m_process;


    [NonSerialized, OdinSerialize]
    [SerializeField]
    List<DemonPhrase> m_demonPhrases = new List<DemonPhrase>();

    [SerializeField] DemonSpeaker m_speaker;


    [SerializeField] BaseTextEffectLogic m_baseEffect;

    [SerializeField] GameObject m_mustActivate;
    [SerializeField] Transform m_effetAScale;
    [SerializeField] UnityEngine.UI.Image m_turnToWhite;

    int m_currentIndexOfDemonPhrase = 0;
    List<DemonPhrase> m_currentList;

    int m_currentIndex = -1;

    int m_failCount = 0;

    [SerializeField] float m_delayFirst = 2f;

    SubscriberList m_subscriberList = new SubscriberList();
    const string m_nextLevelName = "Outro";

    private void Start()
    {
        m_currentList = m_demonPhrases;

        m_subscriberList.Add(new Event<DialongWithDemonEnd>.Subscriber(onDialogEnd));
        m_subscriberList.Add(new Event<MaskAnswerEvent>.Subscriber(onMaskFinish));
        m_subscriberList.Add(new Event<EndBackforwardSceneEvent>.Subscriber(onSceneEnd));
        m_subscriberList.Add(new Event<DemonDoneTalkingDataEvent>.Subscriber(onTextFinished));
        m_subscriberList.Subscribe();

        foreach(var c in m_process)
        {
            if(c.execDiscution)
                c.discution.gameObject.SetActive(false);
            if(c.execMasks)
                c.masks.gameObject.SetActive(false);
            if(c.execScene)
                c.scene.gameObject.SetActive(false);
        }


        DOVirtual.DelayedCall(m_delayFirst, () => startNextStep());
    }

    private void OnDestroy()
    {
        m_subscriberList.Unsubscribe();
    }

    void startNextStep()
    {
        m_currentIndex++;
        if(m_currentIndex >= m_process.Count)
        {
            DOVirtual.DelayedCall(1.5f, () =>
            {
                execEnd();
            });
            return;
        }

        processDiscution();
    }

    void execEnd()
    {
        startText();
    }

    void processDiscution()
    {
        if (m_process[m_currentIndex].execDiscution)
        {
            m_process[m_currentIndex].discution.gameObject.SetActive(true);
            m_process[m_currentIndex].discution.startText();
        }
        else processMasks();
    }

    void onfailMasks()
    {
        m_failCount++;
        processMasks();
    }

    void processMasks()
    {
        if (m_process[m_currentIndex].execMasks)
        {
            m_process[m_currentIndex].masks.gameObject.SetActive(true);
            m_process[m_currentIndex].masks.startMasks();
        }
        else processScene();
    }

    void processScene()
    {
        if (m_process[m_currentIndex].execScene)
        {
            m_process[m_currentIndex].scene.gameObject.SetActive(true);
            m_process[m_currentIndex].scene.startTimeline();

            lightIntensity1 = folletLight1.intensity;
            lightIntensity2 = folletLight2.intensity;

            folletLight1.DOIntensity(0, 1f);
            folletLight2.DOIntensity(0, 1f);
        }
        else startNextStep();
    }

    void onDialogEnd(DialongWithDemonEnd e)
    {
        m_process[m_currentIndex].discution.gameObject.SetActive(false);
        processMasks();
    }

    void onMaskFinish(MaskAnswerEvent e)
    {
        m_process[m_currentIndex].masks.gameObject.SetActive(false);
        if(!e.valid)
        {
            onfailMasks();
        }
        else processScene();
    }

    void onSceneEnd(EndBackforwardSceneEvent e)
    {
        folletLight1.DOIntensity(lightIntensity1, 1f);
        folletLight2.DOIntensity(lightIntensity2, 1f);

        m_process[m_currentIndex].scene.gameObject.SetActive(false);
        Event<TimelineFastForwardEvent>.Broadcast(new TimelineFastForwardEvent(false, true));
        Event<TimelinePauseEvent>.Broadcast(new TimelinePauseEvent(false));
        startNextStep();
    }

    public void startText()
    {
        m_currentIndexOfDemonPhrase = 0;
        m_speaker.gameObject.SetActive(true);
        sayCurrentMessage();
    }

    bool doneTalking = false;
    void sayCurrentMessage()
    {
        if (m_currentIndexOfDemonPhrase >= m_currentList.Count)
        {
            Event<DemonSpeakDataEvent>.Broadcast(null);
            doneTalking = true;
            //loadEndScene
            if (doneEffect)
            {
                SceneSystem.changeScene(m_nextLevelName);
            }
            return;
        }

        if(m_currentIndexOfDemonPhrase == m_currentList.Count-1)
        {
            StartCoroutine(launchEffect());
        }

        DemonPhrase dp = m_demonPhrases[m_currentIndexOfDemonPhrase];

        Event<DemonSpeakDataEvent>.Broadcast(new DemonSpeakDataEvent(dp, m_baseEffect));
    }
    bool doneEffect = false;
    IEnumerator launchEffect()
    {
        yield return null;
        // BLA ICI !
        m_mustActivate.SetActive(true);
        DG.Tweening.Tween P = m_effetAScale.DOScale(85f, 8f);
        yield return new WaitForSeconds(6);
        DG.Tweening.Tween PE = m_turnToWhite.DOFade(1f, 3f);
        yield return PE.WaitForCompletion();
        yield return new WaitForSeconds(1f);

        doneEffect = true;
        if (doneTalking)
        {
            SceneSystem.changeScene(m_nextLevelName);
        }
    }

    void onTextFinished(DemonDoneTalkingDataEvent e)
    {
        if(m_currentIndex >= m_process.Count)
        {
            if (e.indexOfAnswer >= 0)
            {
                m_currentList = m_currentList[m_currentIndexOfDemonPhrase].playerChoices[e.indexOfAnswer].DemonPhraseSayAfter;
                m_currentIndexOfDemonPhrase = 0;
            }
            else m_currentIndexOfDemonPhrase++;

            sayCurrentMessage();
        }
    }
}
