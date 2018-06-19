using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotatorObject : MonoBehaviour {
    

	void Update () {
        transform.Rotate(Vector3.up * Time.deltaTime * 15f);
    }
}
