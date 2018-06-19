using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine.UI;
using DG.Tweening;
using System;
using TMPro;

public class PauseNotebookLogic : MonoBehaviour
{
    [Serializable]
    class ProfilePic
    {
        public string name;
        public Sprite pic;
    }

    enum State
    {
        Summary,
        Characters
    }

    [SerializeField] GameObject m_buttonPrefab;
    [SerializeField] Vector2 m_origineButtons;
    [SerializeField] float m_buttonsDistance;
    [SerializeField] List<ProfilePic> m_pictures;
    [SerializeField] float m_textSwitchTime = 1.0f;
    [SerializeField] float m_maxTextHeight = 100;

    List<GameObject> m_buttonsObjects = new List<GameObject>();
    Text m_sectionTitle;
    TextMeshProUGUI m_sectionText;

    Text m_characterTitle;
    TextMeshProUGUI m_characterText;
    Image m_characterImage;
    Image m_backCharacterImage;

    MenuButton m_objectsButton;
    MenuButton m_charactersButton;

    GameObject m_nextButton;
    GameObject m_previousButton;

    State m_state = State.Summary;

    Color m_selectedColor;
    Color m_otherColor;

    int m_currentPage = 0;
    bool m_canGoNext = false;
    string m_currentName = "";

    private void Awake()
    {
        m_sectionTitle = transform.Find("TitleSection").GetComponent<Text>();
        m_sectionText = transform.Find("TextSection").GetComponent<TextMeshProUGUI>();

        m_characterTitle = transform.Find("TitleCharacter").GetComponent<Text>();
        m_characterText = transform.Find("TextCharacter").GetComponent<TextMeshProUGUI>();
        m_characterImage = transform.Find("Image").GetComponent<Image>();
        m_backCharacterImage = transform.Find("BackImage").GetComponent<Image>();

        m_objectsButton = transform.Find("ObjectsButton").GetComponent<MenuButton>();
        m_charactersButton = transform.Find("CharactersButton").GetComponent<MenuButton>();

        m_nextButton = transform.Find("NextButton").gameObject;
        m_previousButton = transform.Find("PreviousButton").gameObject;

        m_selectedColor = m_objectsButton.colors.pressedColor;
        m_otherColor = m_objectsButton.colors.normalColor;
    }

    private void OnEnable()
    {
        show();
    }

    private void OnDisable()
    {
        hideAll();
    }

    void onSelectSection(string name, bool hideName = true)
    {
        m_currentName = name;

        if (m_sectionTitle.text == name && hideName)
            return;

        if(hideName)
            m_currentPage = 0;

        Color cTitle = m_sectionTitle.color;
        Color cSection = m_sectionText.color;
        if(hideName)
            m_sectionTitle.DOColor(new Color(cTitle.r, cTitle.g, cTitle.b, 0), m_textSwitchTime / 2);
        m_sectionText.DOColor(new Color(cSection.r, cSection.g, cSection.b, 0), m_textSwitchTime / 2).OnComplete(()=>
        {
            m_sectionTitle.text = name;
            setSectionText(name, m_currentPage);
            selectNavigationButtons();

            if (hideName)
                m_sectionTitle.DOColor(new Color(cTitle.r, cTitle.g, cTitle.b, 1), m_textSwitchTime / 2);
            m_sectionText.DOColor(new Color(cSection.r, cSection.g, cSection.b, 1), m_textSwitchTime / 2);
        });
    }

    void setSectionText(string name, int page)
    {
        int textsIndex = 0;
        string text = "";
        var texts = Notebook.instance.getSection(name);
        m_canGoNext = true;

        for (int i = 0; i <= page; i++)
        {
            int textCount = 0;
            Bounds bounds = new Bounds();
            do
            {
                if (text.Length > 0)
                    text += "\n\n";
                text += texts[textsIndex];
                textsIndex++;
                textCount++;
                m_sectionText.text = text;
                m_sectionText.ForceMeshUpdate();
                bounds = m_sectionText.textBounds;
            } while (bounds.extents.y <= m_maxTextHeight && textsIndex < texts.Count);

            if(bounds.extents.y <= m_maxTextHeight)
            {
                m_canGoNext = false;
                break;
            }
            else if(i >= page)
            {
                if (textCount > 1)
                {
                    textsIndex--;
                    text = text.Substring(0, text.Length - texts[textsIndex].Length);
                }
                m_sectionText.text = text;
                m_sectionText.ForceMeshUpdate();
                break;
            }

            if (textCount > 1)
                textsIndex--;
            text = "";
        }
    }

    void onSelectCharacter(string name, bool hideName = true)
    {
        m_currentName = name;
        if(m_characterTitle.text == name && hideName)
            return;

        if (hideName)
            m_currentPage = 0;

        Color cTitle = m_characterTitle.color;
        Color cText = m_characterText.color;

        if (hideName)
        {
            m_characterImage.DOColor(new Color(1, 1, 1, 0), m_textSwitchTime / 2);
            m_backCharacterImage.DOColor(new Color(1, 1, 1, 0), m_textSwitchTime / 2);
            m_characterTitle.DOColor(new Color(cTitle.r, cTitle.g, cTitle.b, 0), m_textSwitchTime / 2);
        }

        m_characterText.DOColor(new Color(cText.r, cText.g, cText.b, 0), m_textSwitchTime / 2).OnComplete(()=>
        {
            m_characterTitle.text = name;
            setCharacterText(name, m_currentPage);

            selectNavigationButtons();

            var img = m_pictures.Find(x => { return x.name == name; });
            if (img == null)
            {
                m_characterImage.gameObject.SetActive(false);
                m_backCharacterImage.gameObject.SetActive(false);
            }
            else
            {
                m_characterImage.gameObject.SetActive(true);
                m_backCharacterImage.gameObject.SetActive(true);
                m_characterImage.sprite = img.pic;
            }

            if (hideName)
            {
                m_characterImage.DOColor(Color.white, m_textSwitchTime / 2);
                m_backCharacterImage.DOColor(Color.white, m_textSwitchTime / 2);
                m_characterTitle.DOColor(new Color(cTitle.r, cTitle.g, cTitle.b, 1), m_textSwitchTime / 2);
            }

            m_characterText.DOColor(new Color(cText.r, cText.g, cText.b, 1), m_textSwitchTime / 2);
        });
    }

    void setCharacterText(string name, int page)
    {
        int textsIndex = 0;
        string text = "";
        var texts = Notebook.instance.getCharacter(name);
        m_canGoNext = true;

        for (int i = 0; i <= page; i++)
        {
            int textCount = 0;
            Bounds bounds = new Bounds();
            do
            {
                if (text.Length > 0)
                    text += "\n\n";
                text += texts[textsIndex];
                textsIndex++;
                textCount++;
                m_characterText.text = text;
                m_characterText.ForceMeshUpdate();
                bounds = m_characterText.textBounds;
            } while (bounds.extents.y <= m_maxTextHeight && textsIndex < texts.Count);

            if (bounds.extents.y <= m_maxTextHeight)
            {
                m_canGoNext = false;
                break;
            }
            else if (i >= page)
            {
                if (textCount > 1)
                {
                    textsIndex--;
                    text = text.Substring(0, text.Length - texts[textsIndex].Length);
                }
                m_characterText.text = text;
                m_characterText.ForceMeshUpdate();
                break;
            }

            if (textCount > 1)
                textsIndex--;
            text = "";

            if(textsIndex >= texts.Count)
            {
                m_currentPage = page - 1;
                setCharacterText(name, page - 1);
                return;
            }
        }
    }

    void selectNavigationButtons()
    {
        var nextButton = m_nextButton.GetComponent<Button>();
        var previousButton = m_previousButton.GetComponent<Button>();

        //yes that's shit, like unity UI !
        /*var nextState = (int)(nextButton.GetType().GetProperty("currentSelectionState", BindingFlags.Instance | BindingFlags.NonPublic).GetGetMethod().Invoke(nextButton, null));
        var previousState = (int)(previousButton.GetType().GetProperty("currentSelectionState", BindingFlags.Instance | BindingFlags.NonPublic).GetGetMethod().Invoke(nextButton, null));

        bool nextSelected = m_nextButton.activeSelf && (nextState == 1 || nextState == 2);
        bool previousSelected = m_previousButton.activeSelf && (previousState == 1 || previousState == 2);*/

        m_nextButton.SetActive(m_canGoNext);
        m_previousButton.SetActive(m_currentPage > 0);

        /*if ((nextSelected && m_nextButton.activeSelf) || (previousSelected && m_previousButton.activeSelf))
            return;

        if (!nextSelected && !previousSelected)
            return;*/

        if (m_nextButton.activeSelf)
            nextButton.Select();
        else if (m_previousButton.activeSelf)
            previousButton.Select();
    }

    public void onSwitch()
    {
        if (m_state == State.Characters)
            m_state = State.Summary;
        else if (m_state == State.Summary)
            m_state = State.Characters;

        show();
    }

    public void onSelectCharacters()
    {
        if (m_state == State.Characters)
            return;

        m_state = State.Characters;
        show();
    }

    public void onSelectObjects()
    {
        if (m_state == State.Summary)
            return;

        m_state = State.Summary;
        show();
    }

    public void onNextPage()
    {
        if (!m_canGoNext)
            return;

        m_currentPage++;

        if (m_state == State.Characters)
            onSelectCharacter(m_currentName, false);
        else onSelectSection(m_currentName, false);
    }

    public void onPreviousPage()
    {
        if (m_currentPage <= 0)
            return;

        m_currentPage--;

        if (m_state == State.Characters)
            onSelectCharacter(m_currentName, false);
        else onSelectSection(m_currentName, false);
    }

    void show()
    {
        if (m_state == State.Characters)
        {
            var charColors = m_charactersButton.colors;
            charColors.normalColor = m_selectedColor;
            m_charactersButton.colors = charColors;
            m_charactersButton.normalStyle = FontStyle.Bold;
            var objColors = m_objectsButton.colors;
            objColors.normalColor = m_otherColor;
            m_objectsButton.colors = objColors;
            m_objectsButton.normalStyle = FontStyle.Normal;

            showCharacters();
        }
        else if (m_state == State.Summary)
        {
            var charColors = m_charactersButton.colors;
            charColors.normalColor = m_otherColor;
            m_charactersButton.colors = charColors;
            m_charactersButton.normalStyle = FontStyle.Normal;
            var objColors = m_objectsButton.colors;
            objColors.normalColor = m_selectedColor;
            m_objectsButton.colors = objColors;
            m_objectsButton.normalStyle = FontStyle.Bold;

            showSummary();
        }

        m_nextButton.SetActive(false);
        m_previousButton.SetActive(false);
    }

    void showSummary()
    {
        hideAll();

        m_sectionTitle.gameObject.SetActive(true);
        m_sectionText.gameObject.SetActive(true);

        m_sectionTitle.text = "";
        m_sectionText.text = "";

        var pos = m_origineButtons;

        foreach (var section in Notebook.instance.getSectionList())
        {
            var button = Instantiate(m_buttonPrefab, transform);
            button.transform.localPosition = pos;
            var text = button.transform.Find("Text").GetComponent<Text>();
            text.text = section;

            pos.y += m_buttonsDistance;

            var b = button.GetComponent<Button>();
            b.onClick.AddListener(delegate { onSelectSection(section); });

            if (m_buttonsObjects.Count == 0)
                DOVirtual.DelayedCall(0.01f, () => { if(b != null) b.Select(); });

            m_buttonsObjects.Add(button);
        }

        if (m_buttonsObjects.Count == 0)
            DOVirtual.DelayedCall(0.01f, () => { transform.Find("ReturnButton").GetComponent<Button>().Select(); });
    }

    void showCharacters()
    {
        hideAll();

        m_characterTitle.gameObject.SetActive(true);
        m_characterText.gameObject.SetActive(true);

        m_characterTitle.text = "";
        m_characterText.text = "";
        m_characterImage.sprite = null;

        var pos = m_origineButtons;

        foreach (var section in Notebook.instance.getCharacterList())
        {
            var button = Instantiate(m_buttonPrefab, transform);
            button.transform.localPosition = pos;
            var text = button.transform.Find("Text").GetComponent<Text>();
            text.text = section;

            pos.y += m_buttonsDistance;

            var b = button.GetComponent<Button>();
            b.onClick.AddListener(delegate { onSelectCharacter(section); });

            if (m_buttonsObjects.Count == 0)
                DOVirtual.DelayedCall(0.01f, () => { b.Select(); });

            m_buttonsObjects.Add(button);
        }

        if (m_buttonsObjects.Count == 0)
            DOVirtual.DelayedCall(0.01f, () => { transform.Find("ReturnButton").GetComponent<Button>().Select(); });
    }

    void hideAll()
    {
        foreach (var b in m_buttonsObjects)
            Destroy(b);
        m_buttonsObjects.Clear();

        m_sectionTitle.gameObject.SetActive(false);
        m_sectionText.gameObject.SetActive(false);

        m_characterTitle.gameObject.SetActive(false);
        m_characterText.gameObject.SetActive(false);
        m_characterImage.gameObject.SetActive(false);
        m_backCharacterImage.gameObject.SetActive(false);
    }
}
