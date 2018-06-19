using System;
using UnityEngine;

public class Letter
{
    public Letter(int _index)
    {
        index = _index;
        isVisible = false;
    }
    public Letter(Vector3[] _VV, Color32[] _VC,Vector2[] _UV0, Vector2[] _UV2,
         int _vertexIndex, int _index, bool _isVisible = true)
    {
        VC = _VC;
        VV = _VV;
        UV0 = _UV0;
        UV2 = _UV2;


        vertexIndex = _vertexIndex;

        initialVV = new Vector3[4];
        initialVV[0] = VV[0 + vertexIndex];
        initialVV[1] = VV[1 + vertexIndex];
        initialVV[2] = VV[2 + vertexIndex]; 
        initialVV[3] = VV[3 + vertexIndex];

        initialVC = new Color32[4];
        initialVC[0] = VC[0 + vertexIndex];
        initialVC[1] = VC[1 + vertexIndex];
        initialVC[2] = VC[2 + vertexIndex];
        initialVC[3] = VC[3 + vertexIndex];

        isVisible = _isVisible;
        index = _index;
    }

    public Vector3 position = Vector3.zero;
    public Vector3[] VV;
    public Color32[] VC;
    public Vector2[] UV0;
    public Vector2[] UV2;
    public int index;

    public readonly Vector3[] initialVV;  // 4
    public readonly Color32[] initialVC; // 4

    public readonly int vertexIndex;
    public readonly bool isVisible;
}

