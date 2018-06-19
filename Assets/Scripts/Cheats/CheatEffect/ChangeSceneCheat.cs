using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ChangeSceneCheat : BaseCheatEffect
{
    string text = "";

    public override void onGui()
    {
        GUI.Label(new Rect(20, 20, 200, 20), "Enter new scene name");
        text = GUI.TextField(new Rect(20, 50, 200, 20), text);
    }

    public override bool onUpdate()
    {
        if (Input.GetKeyDown("return"))
        {
            SceneManager.LoadScene(text);
            text = "";
            return false;
        }
        if(Input.GetKeyDown("escape"))
        {
            text = "";
            return false;
        }

        return true;
    }
}
