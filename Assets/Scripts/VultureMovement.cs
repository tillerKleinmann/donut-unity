using UnityEngine;
using UnityEngine.InputSystem;

public class VultureTurn : MonoBehaviour
{
    public InputActionAsset InputActions;


    private InputAction m_moveAction, incrVisRad, decrVisRad;

    private Rigidbody2D vulture;

    private Vector2 m_moveVulture;

    private float vultureScale = 0.1f;

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
        vulture = GetComponent<Rigidbody2D>();
        
        m_moveAction = InputSystem.actions.FindAction("Move");

        incrVisRad  =  InputSystem.actions.FindAction( "Increase Vision Radius" );
        decrVisRad  =  InputSystem.actions.FindAction( "Decrease Vision Radius" );
    }

    private void FixedUpdate()
    {
        m_moveVulture = m_moveAction.ReadValue<Vector2>();
        if( m_moveVulture.magnitude > 0 )
            vulture.rotation = 270 - Mathf.Atan2(m_moveVulture.x, m_moveVulture.y) * 360 / (2 * Mathf.PI);

        if( incrVisRad.WasPressedThisFrame() )
        {
            vultureScale /= Mathf.Exp(Mathf.Log(2) / 4);
            gameObject.transform.localScale = new Vector3(vultureScale, vultureScale, vultureScale);
        }

        if( decrVisRad.WasPressedThisFrame() )
        {
            vultureScale *= Mathf.Exp(Mathf.Log(2) / 4);
            gameObject.transform.localScale = new Vector3(vultureScale, vultureScale, vultureScale);
        }
    }
}
