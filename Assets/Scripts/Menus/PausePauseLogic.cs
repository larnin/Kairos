using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using DG.Tweening;
using UnityEngine.SceneManagement;

public class PausePauseLogic : MonoBehaviour
{
    [SerializeField] string m_tutorialSceneName = "Scene_Prison";

    private void OnEnable()
    {
        //need to wait a little before select
        DOVirtual.DelayedCall(0.01f, () => { transform.Find("ResumeButton").GetComponent<Button>().Select();});

        var tuto = transform.Find("TutoButton");
        if (tuto != null && (SaveAttributes.getTutoFinished() || SceneManager.GetActiveScene().name != m_tutorialSceneName))
            Destroy(tuto.gameObject);
    }
}
