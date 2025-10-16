using UnityEngine;
using UnityEditor;
using UnityEngine.InputSystem;

public class ScreenScript : MonoBehaviour
{
    public InputActionAsset InputActions;

    public float vultureMoveSpeed;

    public float visionRadius = 2;

    public int accuracy = 64;

    public int surfaceNumber;

    public int textureNumber;

    public Texture texture_FlatTorus, texture_PseudoTorus, texture_Camel, texture_Dromedar, texture_InverseDromedar;


    private InputAction m_moveAction, m_previousAction, m_nextAction, m_increaseVisRad, m_decreaseVisRad, m_increaseAccuracy, m_decreaseAccuracy, nextTexture, previousTexture;

    private Vector2 m_moveVulture;


    Material material;

    private void Start()
    {
        material = GetComponent<Renderer>().material;
        m_moveAction = InputSystem.actions.FindAction("Move");
        m_previousAction = InputSystem.actions.FindAction("Previous Metric");
        m_nextAction = InputSystem.actions.FindAction("Next Metric");
        m_increaseAccuracy = InputSystem.actions.FindAction("Increase Accuracy");
        m_decreaseAccuracy = InputSystem.actions.FindAction("Decrease Accuracy");
        m_increaseVisRad = InputSystem.actions.FindAction("Increase Vision Radius");
        m_decreaseVisRad = InputSystem.actions.FindAction("Decrease Vision Radius");
    }

    private Vector2 confun_d(Vector2 p, int n)
    {
        switch (n)
        {
            case 1:
                return new Vector2( 0, 0 );
            case 2:
                return new Vector2( -Mathf.Sin(p.x) / 4, 0 );
            case 3:
                return new Vector2( -Mathf.Sin(p.x) * Mathf.Cos(p.y) / 4, -Mathf.Cos(p.x) * Mathf.Sin(p.y) / 4 );
            case 4:
                return new Vector2( Mathf.Sin(p.x) * ( 1 - Mathf.Cos(p.y) ) / 4, Mathf.Sin(p.y) * ( 1 - Mathf.Cos(p.x) ) / 4 );
            default:
                return new Vector2( Mathf.Sin(p.x) * ( Mathf.Cos(p.y) - 1 ) / 7, Mathf.Sin(p.y) * ( Mathf.Cos(p.x) - 1 ) / 7 );
        }
    }

    private Vector2 christoffel( Vector2 p, Vector2 u, Vector2 v, int n )
    {
        Vector2 cfd  =  confun_d( p, n );

        float a   =   u.x * v.x  -  u.y * v.y;
        float b   =   u.x * v.y  +  u.y * v.x;

        return new Vector2( cfd.x*a + cfd.y*b, -cfd.y*a + cfd.x*b );
    }

    private Vector2 parallel_transport_euler_step(Vector2 x, Vector2 dx, Vector2 y, float dt, int n)
    {
        return y - dt * christoffel(x, dx, y, n);
    }
    
    private void Update()
    {
        bool surfaceNumberChanged = false;

        if( m_nextAction.WasPressedThisFrame() )
        {
            surfaceNumber += 1;
            if (surfaceNumber > 5) surfaceNumber = 1;
            surfaceNumberChanged = true;
        }

        if (m_previousAction.WasPressedThisFrame())
        {
            surfaceNumber -= 1;
            if (surfaceNumber < 1) surfaceNumber = 5;
            surfaceNumberChanged = true;
        }

        if( m_increaseAccuracy.WasPressedThisFrame() )
            accuracy *= 2;

        if (m_decreaseAccuracy.WasPressedThisFrame())
        {
            if( accuracy > 1 )
                accuracy /= 2;
        }

        if( m_increaseVisRad.WasPressedThisFrame() )
            visionRadius *= Mathf.Exp( Mathf.Log( 2 ) / 4 );
            
        if( m_decreaseVisRad.WasPressedThisFrame() )
            visionRadius /= Mathf.Exp( Mathf.Log( 2 ) / 4 );

        if( surfaceNumberChanged )
            switch (surfaceNumber)
            {
                case 1:
                    material.shader = Shader.Find("Custom/FlatTorus");
                    material.SetTexture("_BaseMap", AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Textures/Tilings/Flat/flat_1.png"));
                    break;
                case 2:
                    material.shader = Shader.Find("Custom/PseudoTorus");
                    material.SetTexture("_BaseMap", texture_PseudoTorus);
                    break;
                case 3:
                    material.shader = Shader.Find("Custom/Camel");
                    material.SetTexture("_BaseMap", texture_Camel);
                    break;
                case 4:
                    material.shader = Shader.Find("Custom/Dromedar");
                    material.SetTexture("_BaseMap", texture_Dromedar);
                    break;
                default:
                    material.shader = Shader.Find("Custom/InverseDromedar");
                    material.SetTexture("_BaseMap", texture_InverseDromedar);
                    break;
            }
        
        material.SetFloat("_VisRad",visionRadius);
        material.SetFloat("_Accuracy",accuracy);
    }

    private void FixedUpdate()
    {
        m_moveVulture = m_moveAction.ReadValue<Vector2>();

        Vector4 camPos  =  material.GetVector( "_CamPos" );
        float   camAng  =  material.GetFloat(  "_CamAng" );

        Vector2  pos  =  new Vector2( camPos.x, camPos.y );
        Vector2  vel  =  new Vector2( -m_moveVulture.x, -m_moveVulture.y ) * vultureMoveSpeed;

        float a  =  -camAng * ( 2*Mathf.PI ) / 360;

        float c = Mathf.Cos(a);
        float s = Mathf.Sin(a);

        vel = new Vector2( c*vel.x + s*vel.y, -s*vel.x + c*vel.y );

        float dt = Time.deltaTime;
        float da = 0;

        Vector2 new_pos = pos + dt * vel;
        Vector2 accel = -christoffel(pos, vel, vel, surfaceNumber);

        if( vel.magnitude > 0 )
            da  =  dt * ( accel.x*vel.y - accel.y*vel.x ) / ( vel.x*vel.x + vel.y*vel.y );

        camPos.x = new_pos.x;
        camPos.y = new_pos.y;
        
        camAng  =  camAng - da*360/(2*Mathf.PI);

        material.SetVector("_CamPos", camPos);
        material.SetFloat("_CamAng", camAng);
    }
}
