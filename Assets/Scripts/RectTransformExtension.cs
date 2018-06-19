using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public static class RectTransformExtension
{
    public enum HAlignement
    {
        LEFT,
        RIGHT,
        CENTRED
    }
    public enum VAlignement
    {
        UP,
        DOWN,
        CENTRED
    }

    public static void SetWidth(this RectTransform transform, float width, HAlignement alignement = HAlignement.CENTRED)
    {
        var min = transform.offsetMin;
        var max = transform.offsetMax;
        var offset = width - (max.x - min.x);

        switch(alignement)
        {
            case HAlignement.CENTRED:
                min.x -= offset / 2.0f;
                max.x += offset / 2.0f;
                break;
            case HAlignement.RIGHT:
                min.x -= offset;
                break;
            case HAlignement.LEFT:
                max.x += offset;
                break;
        }

        transform.offsetMin = min;
        transform.offsetMax = max;
    }

    public static float GetWidth(this RectTransform transform)
    {
        return transform.offsetMax.x - transform.offsetMin.x;
    }

    public static void SetHeight(this RectTransform transform, float height, VAlignement alignement = VAlignement.CENTRED)
    {
        var min = transform.offsetMin;
        var max = transform.offsetMax;
        var offset = height - (max.y - min.y);

        switch (alignement)
        {
            case VAlignement.CENTRED:
                min.y -= offset / 2.0f;
                max.y += offset / 2.0f;
                break;
            case VAlignement.UP:
                min.y -= offset;
                break;
            case VAlignement.DOWN:
                max.y += offset;
                break;
        }

        transform.offsetMin = min;
        transform.offsetMax = max;
    }

    public static float GetHeight(this RectTransform transform)
    {
        return transform.offsetMax.y - transform.offsetMin.y;
    }
}
