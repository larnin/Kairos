using UnityEngine;
using System.Collections;

public class ChangeParentEnableEffect : MonoBehaviour
{

	[SerializeField] Transform m_parent;
	[SerializeField] Transform m_child;

	Transform m_oldparent;

	private void OnEnable()
	{
		m_oldparent = m_child.parent;
		m_child.SetParent(m_parent);
	}

	private void OnDisable()
	{
		m_child.SetParent(m_oldparent);
	}
}
