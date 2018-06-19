using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CheatDebugLogic : MonoBehaviour {
	
	// Update is called once per frame
	void Update () {
        if(Input.GetKeyDown(KeyCode.F1))
        {
            SaveSystem.instance().reset();
           // UnityEngine.SceneManagement.SceneManager.LoadScene(UnityEngine.SceneManagement.SceneManager.GetActiveScene().name);
        }
        

    }
}
