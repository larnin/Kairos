using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using Sirenix.OdinInspector;
using DG.Tweening;

public class ChangeMaterialPropertyEnableEffect : SerializedMonoBehaviour
{

	[Serializable]

	public abstract class PropertyBase
	{
		public string name;

		public abstract void exec(Material m);

		public abstract void ease(Material m, float time, Ease ease);

		public abstract PropertyBase get(Material m);

		
	}

	public class PropertyFloat : PropertyBase
	{
		public float value;

		public override void exec(Material m)
		{
			m.SetFloat(name, value);
		}

		public override PropertyBase get(Material m)
		{
			var v = new PropertyFloat();
			v.name = name;
			v.value = m.GetFloat(name);
			return v;
		}

		public override void ease(Material m, float time, Ease ease)
		{
			m.DOFloat(value, name, time).SetEase(ease);
		}
	}

	public class PropertyInt : PropertyBase
	{
		public int value;

		public override void ease(Material m, float time, Ease ease)
		{
			Debug.LogError("INT NOT SUPPORTED TO EASE");
			exec(m);
		}

		public override void exec(Material m)
		{
			m.SetInt(name, value);
		}

		public override PropertyBase get(Material m)
		{
			var v = new PropertyInt();
			v.name = name;
			v.value = m.GetInt(name);
			return v;
		}
	}

	public class PropertyColor : PropertyBase
	{
		public Color value;

		public override void ease(Material m, float time, Ease ease)
		{
			m.DOColor(value, name, time).SetEase(ease);
		}

		public override void exec(Material m)
		{
			m.SetColor(name, value);
		}

		public override PropertyBase get(Material m)
		{
			var v = new PropertyColor();
			v.name = name;
			v.value = m.GetColor(name);
			return v;
		}
	}

	public class PropertyVector : PropertyBase
	{
		public Vector4 value;

		public override void ease(Material m, float time, Ease ease)
		{
			m.DOVector(value, name, time).SetEase(ease);
		}

		public override void exec(Material m)
		{
			m.SetVector(name, value);
		}

		public override PropertyBase get(Material m)
		{
			var v = new PropertyVector();
			v.name = name;
			v.value = m.GetVector(name);
			return v;
		}
	}

	public class PropertyTexture : PropertyBase
	{
		public Texture value;

		public override void ease(Material m, float time, Ease ease)
		{
			Debug.LogError("INT NOT SUPPORTED TO EASE");
			exec(m);
		}

		public override void exec(Material m)
		{
			m.SetTexture(name, value);
		}

		public override PropertyBase get(Material m)
		{
			var v = new PropertyTexture();
			v.name = name;
			v.value = m.GetTexture(name);
			return v;
		}
	}

	[SerializeField] bool m_useSkinned;
	[HideIf("m_useSkinned")]
	[SerializeField] MeshRenderer m_mesh;

	[ShowIf("m_useSkinned")]
	[SerializeField] SkinnedMeshRenderer m_skinnedMesh;

	[SerializeField] int m_materialNumber;

	[SerializeField] List<PropertyBase> m_properties = new List<PropertyBase>();


	List<PropertyBase> m_baseProperties = new List<PropertyBase>();

	[SerializeField, HorizontalGroup(Width = 20), HideLabel, LabelWidth(1)] bool m_lerp = false;
	[SerializeField, HorizontalGroup, EnableIf("m_lerp"), LabelWidth(50)] float m_time = 1;
	[SerializeField, HorizontalGroup, EnableIf("m_lerp"), LabelWidth(50)] Ease m_ease = Ease.Linear;

	private void OnEnable()
    {
		Material m = null;

		if (!m_useSkinned && m_mesh != null)
		{
			m = m_mesh.materials[m_materialNumber];
		}

		if (m_useSkinned && m_skinnedMesh != null)
		{
			m = m_skinnedMesh.materials[m_materialNumber];
		}

		if (m == null)
		{
			return;
		}
        

        m_baseProperties.Clear();

        foreach (var p in m_properties)
        {
            m_baseProperties.Add(p.get(m));
			if (m_lerp)
			{
				p.ease(m, m_time, m_ease);
			}
			else
			{
				p.exec(m);
			}
        }

    }



    private void OnDisable()
    {
		Material m = null;

		if (!m_useSkinned && m_mesh != null)
		{
			m = m_mesh.materials[m_materialNumber];
		}

		if (m_useSkinned && m_skinnedMesh != null)
		{
			m = m_skinnedMesh.materials[m_materialNumber];
		}

		if (m == null)
		{
			return;
		}

		foreach (var p in m_baseProperties)
		{
			if (m_lerp)
				p.ease(m, m_time, m_ease);
			else
				p.exec(m);
		}
		m_baseProperties.Clear();
            
    }
}