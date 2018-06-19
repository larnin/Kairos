using System;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Sirenix.OdinInspector;
using System.Collections.Generic;
using DG.Tweening;
using Sirenix.Serialization;

[Serializable]
public class MaterialBehaviour : PlayableBehaviour
{
    [HideInInspector] public MaterialClip _clip;

    [SerializeField] bool _ExecuteInEditMode = false;
    [SerializeField] bool m_allMaterials;
    [HideIf("m_allMaterials")]
    [SerializeField] List<int> m_materialsIndexs;

    bool playing = false;

    public override void OnGraphStart (Playable playable)
    {
        
    }

    public void exec(double time, double start, double end, Renderer renderer)
    {
        if (_ExecuteInEditMode || Application.isPlaying)
        {
            if (playing)
            {
                if (time < start)
                    time = start;
                if (time > end)
                    time = end;
                playing = false;
            }

            if (time < start || time > end)
                return;

            playing = true;
            var t = (time - start) / (end - start);

            foreach (var property in _clip.m_properties)
            {
                for(int i = 0; i < renderer.materials.Length; i++)
                {
                    if(m_allMaterials || m_materialsIndexs.Contains(i))
                    {
                        property.exec(renderer.materials[i], (float)t);
                    }
                }
            }
        }
    }
}
