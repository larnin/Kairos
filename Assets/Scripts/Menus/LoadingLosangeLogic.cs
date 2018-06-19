using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class LoadingLosangeLogic : MonoBehaviour
{
    [SerializeField] float m_partShowTime = 0.1f;
    List<GameObject> parts = new List<GameObject>();

    private void Awake()
    {
        parts.Add(transform.Find("Part1").gameObject);
        parts.Add(transform.Find("Part2").gameObject);
        parts.Add(transform.Find("Part3").gameObject);
        parts.Add(transform.Find("Part4").gameObject);
    }

    private void Update()
    {
        int index = Mathf.RoundToInt(Time.time / m_partShowTime) % 8;

        parts[0].SetActive(index < 4);
        parts[1].SetActive(index < 5 && index > 0);
        parts[2].SetActive(index < 6 && index > 1);
        parts[3].SetActive(index < 7 && index > 2);
    }
}
