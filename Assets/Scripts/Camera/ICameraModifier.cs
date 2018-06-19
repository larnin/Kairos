using UnityEngine;

public struct CameraOffsetInfos
{
    public Vector3 positionOffset;
    public Vector3 targetOffset;
    public Vector3 eulerRotationOffset;

    public static CameraOffsetInfos operator +(CameraOffsetInfos left, CameraOffsetInfos right)
    {
        left.eulerRotationOffset = simplifyAngle(simplifyAngle(left.eulerRotationOffset) + simplifyAngle(right.eulerRotationOffset));
        left.targetOffset += right.targetOffset;
        left.positionOffset += right.positionOffset;
        return left;
    }

    public static CameraOffsetInfos operator -(CameraOffsetInfos left, CameraOffsetInfos right)
    {
        left.eulerRotationOffset = simplifyAngle(simplifyAngle(left.eulerRotationOffset) - simplifyAngle(right.eulerRotationOffset));
        left.targetOffset -= right.targetOffset;
        left.positionOffset -= right.positionOffset;
        return left;
    }

    public static CameraOffsetInfos operator *(CameraOffsetInfos value, float mult)
    {
        value.eulerRotationOffset = simplifyAngle(simplifyAngle(value.eulerRotationOffset) * mult);
        value.targetOffset *= mult;
        value.positionOffset *= mult;
        return value;
    }

    public static CameraOffsetInfos operator /(CameraOffsetInfos value, float mult)
    {
        value.eulerRotationOffset = simplifyAngle(simplifyAngle(value.eulerRotationOffset) / mult);
        value.targetOffset /= mult;
        value.positionOffset /= mult;
        return value;
    }

    static Vector3 simplifyAngle(Vector3 value)
    {
        return new Vector3(simplifyAngle(value.x), simplifyAngle(value.y), simplifyAngle(value.z));
    }

    static float simplifyAngle(float value)
    {
        while (value < -180)
            value += 360;
        while (value > 180)
            value -= 360;
        return value;
    }
}

public interface ICameraModifier
{
    CameraOffsetInfos check(Vector3 position);
}
