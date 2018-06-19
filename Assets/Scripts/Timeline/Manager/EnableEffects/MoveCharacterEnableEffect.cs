using UnityEngine;

public class MoveCharacterEnableEffect : MonoBehaviour
{
    [SerializeField] Transform characterToMove;
    [SerializeField] Vector3 m_newPosition;
    [SerializeField] Vector3 m_newRotation;

	[SerializeField] bool m_shouldRevert;

    Vector3 oldPosition ;
    Vector3 oldRotation ;
    
    void OnEnable()
    {
        oldPosition = characterToMove.position;
        oldRotation = characterToMove.rotation.eulerAngles;

        characterToMove.position = m_newPosition;
        characterToMove.rotation = Quaternion.Euler (m_newRotation);
    }

    void OnDisable()
    {
		if (characterToMove != null && m_shouldRevert)
		{
			characterToMove.position = oldPosition;
			characterToMove.rotation = Quaternion.Euler(oldRotation);
		}
        
    }
}