using UnityEngine;
using UnityEditor;
using UnityEngine.InputSystem;
using TMPro;

public class ScreenScript : MonoBehaviour
{
    private Texture2D tilingTexture, spaceTexture;

    public InputActionAsset InputActions;

    public float vultureMoveSpeed = 2.0f, visionRadius = 2.0f*Mathf.PI, rocketSpeed = 11.0f, rocketInitialLive = 3.142f;

    public int accuracy = 16, metricNumber = 1, textureNumber = 1, gsmNumber = 1;

    private InputAction moveAction, nextMetric, prevMetric, incrVisRad, decrVisRad, incrAccuracy, decrAccuracy, nextTexture, prevTexture, nextGSM, prevGSM, shoot;

    private Vector2 moveVulture;

    private Vector4[] rocketsState = new Vector4[16];
    private float[] rocketsLive = new float[16];
    private int nextRocket = 0;

    private string metricName;

    public TextMeshProUGUI domainField, metricField, textureField, radiusField, GSMField, accuracyField, frameRateField;

    private float pollingTime = 1f, time = 0f;
    private int frameCount = 0;

    Material material;

    private void Awake()
    {
        material = GetComponent<Renderer>().material;

        moveAction = InputSystem.actions.FindAction("Move");

        nextMetric = InputSystem.actions.FindAction("Next Metric");
        prevMetric = InputSystem.actions.FindAction("Previous Metric");

        nextTexture = InputSystem.actions.FindAction("Next Texture");
        prevTexture = InputSystem.actions.FindAction("Previous Texture");

        nextGSM = InputSystem.actions.FindAction("Next GSM");
        prevGSM = InputSystem.actions.FindAction("Previous GSM");

        incrAccuracy = InputSystem.actions.FindAction("Increase Accuracy");
        decrAccuracy = InputSystem.actions.FindAction("Decrease Accuracy");

        incrVisRad = InputSystem.actions.FindAction("Increase Vision Radius");
        decrVisRad = InputSystem.actions.FindAction("Decrease Vision Radius");

        shoot = InputSystem.actions.FindAction("Attack");
    }
    
    private void Start()
    {
        tilingTexture = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Textures/Tilings/" + metricName + "_" + textureNumber.ToString() + ".png");
        material.SetTexture("_BaseMap", tilingTexture);
        //spaceTexture = new Texture2D( tilingTexture.width, tilingTexture.height, tilingTexture.format, false );
    }

    private float confun(Vector2 p, int n)
    {
        switch (n)
        {
            case 1:
                return 0f;
            case 2:
                return Mathf.Cos(p.x) / 4;
            case 3:
                return Mathf.Cos(p.x) * Mathf.Cos(p.y) / 4;
            case 4:
                return (1 - Mathf.Cos(p.x)) * (1 - Mathf.Cos(p.y)) / 4;
            case 5:
                return (2 - (1 - Mathf.Cos(p.x)) * (1 - Mathf.Cos(p.y))) / 7;
            case 6:
                return 0.5f + Mathf.Cos(p.x)*(3-Mathf.Pow(Mathf.Cos(p.x),2))/8;
            default:
                return 0.5f + Mathf.Cos(p.x)*(3-Mathf.Pow(Mathf.Cos(p.x),2))*Mathf.Cos(p.y)*(3-Mathf.Pow(Mathf.Cos(p.y),2))/8;
        }
    }

    private Vector2 confun_grad(Vector2 p, int n)
    {
        switch (n)
        {
            case 1:
                return new Vector2(0, 0);
            case 2:
                return new Vector2(-Mathf.Sin(p.x) / 4, 0);
            case 3:
                return new Vector2(-Mathf.Sin(p.x) * Mathf.Cos(p.y) / 4, -Mathf.Cos(p.x) * Mathf.Sin(p.y) / 4);
            case 4:
                return new Vector2(Mathf.Sin(p.x) * (1 - Mathf.Cos(p.y)) / 4, Mathf.Sin(p.y) * (1 - Mathf.Cos(p.x)) / 4);
            case 5:
                return new Vector2(Mathf.Sin(p.x) * (Mathf.Cos(p.y) - 1) / 7, Mathf.Sin(p.y) * (Mathf.Cos(p.x) - 1) / 7);
            case 6:
                return new Vector2( -3*Mathf.Sin(p.x)*(1-Mathf.Pow(Mathf.Cos(p.x),2))/8, 0 );
            default:
                return new Vector2( -3*Mathf.Sin(p.x)*(1-Mathf.Pow(Mathf.Cos(p.x),2))*Mathf.Cos(p.y)*(3-Mathf.Pow(Mathf.Cos(p.y),2))/8, -3*Mathf.Sin(p.y)*(1-Mathf.Pow(Mathf.Cos(p.y),2))*Mathf.Cos(p.x)*(3-Mathf.Pow(Mathf.Cos(p.x),2))/8 );
        }
    }

    private Vector2 christoffel( Vector2 p, Vector2 u, Vector2 v, int n )
    {
        Vector2 cfd  =  confun_grad( p, n );

        float a   =   u.x * v.x  -  u.y * v.y;
        float b   =   u.x * v.y  +  u.y * v.x;

        return new Vector2( cfd.x*a + cfd.y*b, -cfd.y*a + cfd.x*b );
    }

    private Vector2 parallel_transport_step__euler(Vector2 x, Vector2 dx, Vector2 y, float dt, int n)
    {
        return y - dt * christoffel(x, dx, y, n);
    }

    private void apply_geodesic_step__euler(ref Vector2 p, ref Vector2 v, float dt, int n)
    {
        Vector2 Ga = christoffel(p, v, v, n);

        p += dt * v;
        v -= dt * Ga;
    }
    
    private void apply_geodesic_step__midpoint( ref Vector2 p, ref Vector2 v, float dt, int n )
    {
        Vector2 Ga = christoffel(p, v, v, n);

        Vector2 p_m = p + (dt / 2) * v;
        Vector2 v_m = v - (dt / 2) * Ga;

        Vector2 Ga_m = christoffel(p_m, v_m, v_m, n);

        p  =  p + dt * v_m;
        v  =  v - dt * Ga_m;
    }

    private void propagate_rocket( ref Vector4 rp, float dt, int n )
    {
        Vector2 rp_p = new Vector2(rp.x, rp.y);
        Vector2 rp_v = new Vector2(rp.z, rp.w);

        //apply_geodesic_step__euler(ref rp_p, ref rp_v, dt, n);
        apply_geodesic_step__midpoint( ref rp_p, ref rp_v, dt, n );

        rp = new Vector4( rp_p.x, rp_p.y, rp_v.x, rp_v.y );
    }

    private void Update()
    {
        time += Time.deltaTime;

        frameCount++;

        if (time > pollingTime)
        {
            int frameRate = Mathf.RoundToInt(frameCount / time);
            frameRateField.text = frameRate.ToString();

            time -= pollingTime;
            frameCount = 0;
        }

        bool metricChanged = false;
        bool textureChanged = false;

        if (nextMetric.WasPressedThisFrame())
        {
            metricNumber += 1;
            if (metricNumber > 7) metricNumber = 1;
            metricChanged = true;
        }

        if (prevMetric.WasPressedThisFrame())
        {
            metricNumber -= 1;
            if (metricNumber < 1) metricNumber = 7;
            metricChanged = true;
        }

        if (nextTexture.WasPressedThisFrame())
        {
            textureNumber += 1;
            if (textureNumber > 4) textureNumber = 1;
            textureChanged = true;
        }

        if (prevTexture.WasPressedThisFrame())
        {
            textureNumber -= 1;
            if (textureNumber < 1) textureNumber = 4;
            textureChanged = true;
        }

        if (nextGSM.WasPressedThisFrame())
        {
            gsmNumber += 1;
            if (gsmNumber > 3) gsmNumber = 1;
        }

        if (prevGSM.WasPressedThisFrame())
        {
            gsmNumber -= 1;
            if (gsmNumber < 1) gsmNumber = 3;
        }

        if (incrAccuracy.WasPressedThisFrame())
            accuracy *= 2;

        if (decrAccuracy.WasPressedThisFrame())
            if (accuracy > 1) accuracy /= 2;

        if (incrVisRad.WasPressedThisFrame())
            visionRadius *= Mathf.Exp(Mathf.Log(2) / 4);

        if (decrVisRad.WasPressedThisFrame())
            visionRadius /= Mathf.Exp(Mathf.Log(2) / 4);

        switch (metricNumber)
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
            case 6:
                metricName = "pseudoPlateau";
                break;
            case 7:
                metricName = "camelPlateau";
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

        radiusField.text = string.Format("{0:0.000}", visionRadius);

        switch (gsmNumber)
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

        material.SetFloat("_VisRad", visionRadius);
        material.SetFloat("_Accuracy", accuracy);
        material.SetFloat("_GSM", gsmNumber);

        tilingTexture = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Textures/Tilings/" + metricName + "_" + textureNumber.ToString() + ".png");

        // //spaceTexture = new Texture2D( tilingTexture.width, tilingTexture.height );
        // //spaceTexture.SetPixels(tilingTexture.GetPixels());
        // spaceTexture = new Texture2D( tilingTexture.width, tilingTexture.height, tilingTexture.format, false );
        // spaceTexture.LoadRawTextureData( tilingTexture.GetRawTextureData() );

        // int bs  =  Mathf.RoundToInt(32 * (2 + Mathf.Cos(Time.time)));

        // for( int k = 0; k < bs; k++ )
        //     for( int l = 0; l < bs; l++ )
        //         spaceTexture.SetPixel( k, l, new Color( 0.5f, 0.5f, 0.5f ) );

        // spaceTexture.Apply();

        //material.SetTexture("_BaseMap", spaceTexture);
        material.SetTexture("_BaseMap", tilingTexture);

        if (shoot.WasPressedThisFrame())
        {
            rocketsLive[nextRocket] = rocketInitialLive;
            rocketsState[nextRocket] = material.GetVector("_CamPos");

            float rsf = rocketSpeed * Mathf.Exp(-confun(new Vector2(rocketsState[nextRocket].x, rocketsState[nextRocket].y), metricNumber));

            rocketsState[nextRocket].z *= rsf;
            rocketsState[nextRocket].w *= rsf;

            nextRocket++;
            if (nextRocket > 15)
                nextRocket = 0;
        }
    }
    
    private void move_vulture()
    {
        moveVulture = moveAction.ReadValue<Vector2>();

        Vector4  camPos  =  material.GetVector( "_CamPos" );
        float    camAng  =  material.GetFloat("_CamAng");

        float a = -camAng * (2 * Mathf.PI / 360);

        float c = Mathf.Cos(a);
        float s = Mathf.Sin(a);

        Vector2  pos  =  new Vector2( camPos.x, camPos.y );
        Vector2  vel  =  -moveVulture * vultureMoveSpeed;

        vel  =  new Vector2(c * vel.x + s * vel.y, -s * vel.x + c * vel.y);

        vel  *=  Mathf.Exp( -confun( pos, metricNumber ) );

        float dt = Time.deltaTime;
        float da = 0;

        Vector2  new_pos  =  pos + dt*vel;
        Vector2  accel    =  -christoffel( pos, vel, vel, metricNumber );

        if (vel.magnitude > 0)
            da = dt * (accel.x * vel.y - accel.y * vel.x) / (vel.x * vel.x + vel.y * vel.y);

        new_pos.x = new_pos.x - Mathf.RoundToInt(new_pos.x / (2 * Mathf.PI)) * 2 * Mathf.PI;
        new_pos.y = new_pos.y - Mathf.RoundToInt(new_pos.y / (2 * Mathf.PI)) * 2 * Mathf.PI;

        camPos.x = new_pos.x;
        camPos.y = new_pos.y;

        //Vector2  vulVec  =  new Vector2( camPos.z, camPos.w );
        if (vel.magnitude > 0)
        {
            Vector2 vulVec = vel.normalized;
            camPos.z = vulVec.x;
            camPos.w = vulVec.y;
        }
        
        camAng   =   camAng  -  da * (360/(2*Mathf.PI));

        material.SetVector( "_CamPos", camPos );
        material.SetFloat(  "_CamAng", camAng );
    }

    private void FixedUpdate()
    {
        move_vulture();

        for (int k = 0; k < 16; k++)
        {
            propagate_rocket(ref rocketsState[k], Time.deltaTime, metricNumber);
            if( rocketsLive[k] > 0 )
            rocketsLive[k] -= Time.deltaTime;
        }

        material.SetVectorArray("_RocketsState", rocketsState);
        material.SetFloatArray("_RocketsLive", rocketsLive);
    }
}
