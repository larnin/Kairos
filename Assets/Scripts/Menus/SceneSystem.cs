using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.SceneManagement;
using DG.Tweening;

public static class SceneSystem
{
    const string defaultSceneName = "MainMenu";
    
    public static void changeScene(string sceneName, bool saveSceneChanges = true, Action finishedCallback = null)
    {
        if (!Application.CanStreamedLevelBeLoaded(sceneName))
        {
            Debug.LogError("Can't load scene " + sceneName + ". Back to main menu");
            sceneName = defaultSceneName;
            saveSceneChanges = false;
        }

        if (saveSceneChanges)
            saveNewScene(sceneName);

        Time.timeScale = 1.0f;

        if (sceneName != defaultSceneName)
        {
            Event<ShowLoadingScreenEvent>.Broadcast(new ShowLoadingScreenEvent(true));
            DOVirtual.DelayedCall(1.5f, () =>
            {
                var operation = SceneManager.LoadSceneAsync(sceneName);
                execChangeScene(operation, finishedCallback);
            });
        }
        else
        {
            var operation = SceneManager.LoadSceneAsync(sceneName);
            execChangeScene(operation, finishedCallback);
        }
    }

    static void saveNewScene(string sceneName)
    {
        Event<EndSceneEvent>.Broadcast(new EndSceneEvent());
        Event<TimelineClearEvent>.Broadcast(new TimelineClearEvent());
        Event<SetBalanceOfCoherenceValueEvent>.Broadcast(new SetBalanceOfCoherenceValueEvent(0));

        SaveAttributes.setCurrentScene(sceneName);
    }

    static void execChangeScene(AsyncOperation operation, Action finishedCallback)
    {
        if (!operation.isDone)
            DOVirtual.DelayedCall(0.1f, () => execChangeScene(operation, finishedCallback));
        else
        {
            Event<ShowLoadingScreenEvent>.Broadcast(new ShowLoadingScreenEvent(false));
            if (finishedCallback != null)
                finishedCallback();
        }
    }
}
