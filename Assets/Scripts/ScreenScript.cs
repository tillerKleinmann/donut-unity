using UnityEngine;
using UnityEditor;
using UnityEngine.InputSystem;
using TMPro;

public class ScreenScript : MonoBehaviour
{
    private Texture2D tilingTexture, spaceTexture;

    public InputActionAsset InputActions;

    public float vultureMoveSpeed = 2.0f, visionRadius = 2.0f*Mathf.PI;

    public int accuracy = 16, metricNumber = 1, textureNumber = 1, gsmNumber = 1;

    private InputAction moveAction, nextMetric, prevMetric, incrVisRad, decrVisRad, incrAccuracy, decrAccuracy, nextTexture, prevTexture, nextGSM, prevGSM;

    private Vector2 moveVulture;

    private string metricName;

    public TextMeshProUGUI domainField, metricField, textureField, radiusField, GSMField, accuracyField, frameRateField;

    private float pollingTime = 1f, time = 0f;
    private int frameCount = 0;

    Material material;

    private void Awake()
    {
        material = GetComponent<Renderer>().material;
        
        moveAction  =  InputSystem.actions.FindAction( "Move" );

        nextMetric  =  InputSystem.actions.FindAction( "Next Metric" );
        prevMetric  =  InputSystem.actions.FindAction( "Previous Metric" );

        nextTexture  =  InputSystem.actions.FindAction( "Next Texture" );
        prevTexture  =  InputSystem.actions.FindAction( "Previous Texture" );
        
        nextGSM  =  InputSystem.actions.FindAction( "Next GSM" );
        prevGSM  =  InputSystem.actions.FindAction( "Previous GSM" );

        incrAccuracy  =  InputSystem.actions.FindAction( "Increase Accuracy" );
        decrAccuracy  =  InputSystem.actions.FindAction( "Decrease Accuracy" );

        incrVisRad  =  InputSystem.actions.FindAction( "Increase Vision Radius" );
        decrVisRad  =  InputSystem.actions.FindAction( "Decrease Vision Radius" );
        
        tilingTexture = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Textures/Tilings/" + metricName + "_" + textureNumber.ToString() + ".png");
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
        time += Time.deltaTime;

        frameCount++;

        if( time > pollingTime )
        {
            int  frameRate  =  Mathf.RoundToInt( frameCount / time );
            frameRateField.text  =  frameRate.ToString();

            time -= pollingTime;
            frameCount = 0;
        }

        bool  metricChanged   =  false;
        bool  textureChanged  =  false;

        if( nextMetric.WasPressedThisFrame() )
        {
            metricNumber += 1;
            if( metricNumber > 5 ) metricNumber = 1;
            metricChanged = true;
        }

        if( prevMetric.WasPressedThisFrame() )
        {
            metricNumber -= 1;
            if( metricNumber < 1 ) metricNumber = 5;
            metricChanged = true;
        }

        if( nextTexture.WasPressedThisFrame() )
        {
            textureNumber += 1;
            if( textureNumber > 4 ) textureNumber = 1;
            textureChanged = true;
        }

        if( prevTexture.WasPressedThisFrame() )
        {
            textureNumber -= 1;
            if (textureNumber < 1) textureNumber = 4;
            textureChanged = true;
        }
        
        if( nextGSM.WasPressedThisFrame() )
        {
            gsmNumber += 1;
            if( gsmNumber > 3 ) gsmNumber = 1;
        }

        if( prevGSM.WasPressedThisFrame() )
        {
            gsmNumber -= 1;
            if( gsmNumber < 1 ) gsmNumber = 3;
        }

        if( incrAccuracy.WasPressedThisFrame() )
            accuracy *= 2;

        if( decrAccuracy.WasPressedThisFrame() )
            if( accuracy > 1 )  accuracy /= 2;

        if( incrVisRad.WasPressedThisFrame() )
            visionRadius *= Mathf.Exp( Mathf.Log( 2 ) / 4 );
            
        if( decrVisRad.WasPressedThisFrame() )
            visionRadius /= Mathf.Exp( Mathf.Log( 2 ) / 4 );

        switch( metricNumber )
        {
            case 1:
                metricName = "flat";
                break;
            case 2:
                metricName = "pseudo";
                break;
            case 3:
                metricName = "camel";
                break;
            case 4:
                metricName = "dromedar";
                break;
            case 5:
                metricName = "rademord";
                break;
        }

        if (metricChanged)
        {
            material.shader = Shader.Find("Custom/Confmets/" + metricName);
            metricField.text = metricName;
        }

        if (metricChanged | textureChanged)
        {
            tilingTexture = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Textures/Tilings/" + metricName + "_" + textureNumber.ToString() + ".png");
        }

        if (textureChanged)
            textureField.text = textureNumber.ToString();

        accuracyField.text = accuracy.ToString();
        
        radiusField.text  =  string.Format( "{0:0.000}", visionRadius );

        switch( gsmNumber )
        {
            case 1:
                GSMField.text = "RK4";
                break;
            case 2:
                GSMField.text = "midp";
                break;
            case 3:
                GSMField.text = "euler";
                break;
        }
        
        material.SetFloat( "_VisRad",   visionRadius );
        material.SetFloat( "_Accuracy", accuracy     );
        material.SetFloat("_GSM", gsmNumber);

        //spaceTexture = tilingTexture;
        
        tilingTexture = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Textures/Tilings/" + metricName + "_" + textureNumber.ToString() + ".png");

        for (int k = 0; k < 128; k++)
            for (int l = 0; l < 128; l++)
                tilingTexture.SetPixel(k, l, new Color(0.5f, 0.5f, 0.5f));

        tilingTexture.Apply();

        //material.SetTexture("_BaseMap", spaceTexture);
        material.SetTexture("_BaseMap", tilingTexture);
    }

    private void FixedUpdate()
    {
        moveVulture = moveAction.ReadValue<Vector2>();

        Vector4  camPos  =  material.GetVector( "_CamPos" );
        float    camAng  =  material.GetFloat(  "_CamAng" );

        Vector2  pos  =  new Vector2( camPos.x, camPos.y );
        Vector2  vel  =  new Vector2( -moveVulture.x, -moveVulture.y ) * vultureMoveSpeed;

        float  a  =  -camAng * (2*Mathf.PI/360);

        float  c  =  Mathf.Cos(a);
        float  s  =  Mathf.Sin(a);

        vel  =  new Vector2( c*vel.x + s*vel.y, -s*vel.x + c*vel.y );

        float  dt  =  Time.deltaTime;
        float  da  =  0;

        Vector2  new_pos  =  pos + dt*vel;
        
        Vector2  accel  =  -christoffel( pos, vel, vel, metricNumber );

        if( vel.magnitude > 0 )
            da  =  dt * ( accel.x*vel.y - accel.y*vel.x ) / ( vel.x*vel.x + vel.y*vel.y );

        camPos.x  =  new_pos.x;
        camPos.y  =  new_pos.y;
        
        camAng   =   camAng  -  da * (360/(2*Mathf.PI));

        material.SetVector( "_CamPos", camPos );
        material.SetFloat(  "_CamAng", camAng );
    }
}
