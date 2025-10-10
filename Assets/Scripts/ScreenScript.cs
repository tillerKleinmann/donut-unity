using UnityEngine;
using UnityEngine.InputSystem;

public class ScreenScript : MonoBehaviour
{
    public InputActionAsset InputActions;

    public float vultureMoveSpeed;


    private InputAction m_moveAction;

    private Vector2 m_moveVulture;


    Material material;

    private void Start()
    {
        material = GetComponent<Renderer>().material;

        m_moveAction = InputSystem.actions.FindAction("Move");
    }

    private Vector2 confun_d( Vector2 p )
    {
        // return new Vector2( 0, 0 );
        // return new Vector2( -sin(p.x) / 4, 0 );
        // return new Vector2( -sin(p.x) * cos(p.y) / 4, -cos(p.x) * sin(p.y) / 4 );
        // return new Vector2( sin(p.x) * ( 1 - cos(p.y) ) / 4, sin(p.y) * ( 1 - cos(p.x) ) / 4 );
        return new Vector2( Mathf.Sin(p.x) * ( Mathf.Cos(p.y) - 1 ) / 7, Mathf.Sin(p.y) * ( Mathf.Cos(p.x) - 1 ) / 7 );
    }
    
    private Vector2 christoffel( Vector2 p, Vector2 u, Vector2 v )
    {
        Vector2 cfd  =  confun_d( p );

        float a   =   u.x * v.x  -  u.y * v.y;
        float b   =   u.x * v.y  +  u.y * v.x;

        return new Vector2( cfd.x*a + cfd.y*b, -cfd.y*a + cfd.x*b );
    }

    private Vector2 parallel_transport_euler_step( Vector2 x, Vector2 dx, Vector2 y, float dt )
    {
        return y - dt*christoffel( x, dx, y );
    }

    private void FixedUpdate()
    {
        m_moveVulture = m_moveAction.ReadValue<Vector2>();

        Vector4 camPos = material.GetVector("_CamPos");
        float camAng = material.GetFloat("_CamAng");

        Vector2 pos = new Vector2(camPos.x, camPos.y);
        Vector2 vel = new Vector2(-m_moveVulture.x, -m_moveVulture.y) * vultureMoveSpeed;

        float a = -camAng*(2*Mathf.PI)/360;

        float c = Mathf.Cos(a);
        float s = Mathf.Sin(a);

        vel = new Vector2( c*vel.x + s*vel.y, -s*vel.x + c*vel.y );

        float dt = Time.deltaTime;
        float da = 0;

        Vector2 new_pos = pos + dt * vel;
        Vector2 accel = -christoffel(pos, vel, vel);
        
        if( vel.magnitude > 0 )
            da = dt * ( accel.x*vel.y - accel.y*vel.x ) / ( vel.x*vel.x + vel.y*vel.y );

        camPos.x = new_pos.x;
        camPos.y = new_pos.y;
        camAng = camAng - da*360/(2*Mathf.PI);

        material.SetVector("_CamPos", camPos);
        material.SetFloat("_CamAng", camAng);
    }
}
