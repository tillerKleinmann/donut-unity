using UnityEngine;
using UnityEngine.InputSystem;

public class VultureTurn : MonoBehaviour
{
    public InputActionAsset InputActions;

    //public Material screen;

    private InputAction m_moveAction;

    private Rigidbody2D vulture;

    private Vector2 m_moveVulture;

    public float vultureTurnSpeed;

    private void OnEnable()
    {
        InputActions.FindActionMap("Player").Enable();
    }

    private void OnDisable()
    {
        InputActions.FindActionMap("Player").Disable();
    }

    private void Awake()
    {
        m_moveAction = InputSystem.actions.FindAction("Move");

        vulture = GetComponent<Rigidbody2D>();
    }

    private void FixedUpdate()
    {
        m_moveVulture = m_moveAction.ReadValue<Vector2>();
        if( m_moveVulture.magnitude > 0 )
            vulture.rotation = 270 - Mathf.Atan2( m_moveVulture.x, m_moveVulture.y )*360/(2*Mathf.PI);
    }
}
