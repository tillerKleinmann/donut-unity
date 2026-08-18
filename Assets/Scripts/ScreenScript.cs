using UnityEngine;
using static UnityEngine.Mathf;
using UnityEditor;
using UnityEngine.InputSystem;
using TMPro;

public class ScreenScript : MonoBehaviour
{
    private Texture2D tilingTexture, spaceTexture;

    public InputActionAsset InputActions;

    public float vultureMoveSpeed = 2.0f, visionRadius = 2.0f*PI, rocketSpeed = 11.0f, rocketInitialLive = 3.142f;

    public int accuracy = 16, metricNumber = 1, textureNumber = 1, gsmNumber = 1;

    private InputAction moveAction, nextMetric, prevMetric, incrVisRad, decrVisRad, incrAccuracy, decrAccuracy, nextTexture, prevTexture, nextGSM, prevGSM, nextCT, prevCT, stopVul, shoot, toggleFullscreenRendering, toggleDisplayRoads;

    private Vector2 moveVulture;


    private Vector2 vulPos, vulVel, vulTan, vulNor;

    private Vector4[] rocketsState = new Vector4[16];
    private float[] rocketsLive = new float[16];
    private int nextRocket = 0;

    private int ctNumber = 1;


    private static float rad2deg = 180/PI;
    private static float deg2rad = PI/180;


    private string metricName = "sqFlat";
    private string domainName = "square";

    public TextMeshProUGUI domainField, metricField, textureField, radiusField, GSMField, accuracyField, frameRateField;

    private float pollingTime = 1f, time = 0f;
    private int frameCount = 0;

    private bool fullscreen = false;
    private bool displayRoads = false;

    private float fullscreenFloat = 0f;
    private float displayRoadsFloat = 0f;

    Material material;


    private static Vector2  k0  =  new Vector2(  0.0f,  2/Sqrt(3) );
    private static Vector2  k1  =  new Vector2( +1.0f, -1/Sqrt(3) );
    private static Vector2  k2  =  new Vector2( -1.0f, -1/Sqrt(3) );
    private static Vector2  k3  =  k0 * 2;
    private static Vector2  k4  =  k1 * 2;
    private static Vector2  k5  =  k2 * 2;
    private static Vector2  k6  =  new Vector2(  2.0f, 0.0f );
    private static Vector2  k7  =  new Vector2( -1.0f, -3/Sqrt(3) );
    private static Vector2  k8  =  new Vector2( -1.0f, +3/Sqrt(3) );

    private static Vector2  k3m  =  k3 / 2;
    private static Vector2  k4m  =  k4 / 2;
    private static Vector2  k5m  =  k5 / 2;
    private static Vector2  k6m  =  k6 / 2;
    private static Vector2  k7m  =  k7 / 2;
    private static Vector2  k8m  =  k8 / 2;


    private float skap( Vector2 p, Vector2 k ){ return p.x*k.x + p.y*k.y; }

    private float cop( Vector2 p, Vector2 k ){ return Cos(skap(k,p)); }
    private float sip( Vector2 p, Vector2 k ){ return Sin(skap(k,p)); }


    private struct VultureState
    {
        public Vector2 pos; // Position (vector)
        public Vector2 vel; // Velocity (vector)
        public Vector2 tan; // Tangent Vector (normalized vector)
        public Vector2 nor; // Normal Vector (normalized vector, for immersed surfaces: binormal vector in the Darboux frame)
        public float ang; // Angle (real number, relative to the standard x-coordinate vector)
        public float sgn; // Sign (can be +1 or -1, means orientation)
    }

    private struct VultureProperties
    {
        public float speed;
    }

    private struct Vulture
    {
        public VultureState state;
        public VultureProperties props;
    }

    private Vulture vulture;

    private struct DomainParameters
    {
        public float a;
        public float b;
        public float ga_deg;
        public float ga_rad;
        public Vector2 va;
        public Vector2 vb;
        public Vector2 av;
        public Vector2 bv;
    }

    private DomainParameters domainParameters;
    
    private DomainParameters make_domain_parameters( float a, float b, float ga_deg )
    {
        DomainParameters DP;

        DP.a = a;
        DP.b = b;
        DP.ga_deg = ga_deg;

        DP.ga_rad = ga_deg * deg2rad;

        float c = Cos(DP.ga_rad);
        float s = Sin(DP.ga_rad);

        DP.va = new Vector2(a, 0);
        DP.vb = new Vector2(-b * c, b * s);

        DP.av = new Vector2(1 / a, c / (a * s));
        DP.bv = new Vector2(0, 1 / (b * s));

        return DP;
    }

    private float psqueeze3( float x )
    {
        return x * ( 3 - x*x ) / 2;
    }

    private float psqueeze3_d( float x )
    {
        return ( 1 - x*x ) * 3/2;
    }

    private float psqueeze5( float x )
    {
        return x * ( 15 - 10*x*x + 3*Pow(x,4) ) / 8;
    }

    private float psqueeze5_d( float x )
    {
        return ( 1 - 2*x*x + Pow(x,4) ) * 15/8;
    }

    private float confun(Vector2 p, int n)
    {
        switch (n)
        {
            case 1:
                return 0f;
            case 2:
                return Cos(p.x) / 4;
            case 3:
                return Cos(p.x) * Cos(p.y) / 4;
            case 4:
                return (1 - Cos(p.x)) * (1 - Cos(p.y)) / 4;
            case 5:
                return (2 - (1 - Cos(p.x)) * (1 - Cos(p.y))) / 7;
            case 6:
                return 0.5f + Cos(p.x)*(3-Pow(Cos(p.x),2))/8;
            case 7:
                return 0.5f + Cos(p.x) * (3 - Pow(Cos(p.x), 2)) * Cos(p.y) * (3 - Pow(Cos(p.y), 2)) / 8;
            case 8:
                return 0f;
            case 9:
                return Log( 5 ) - Log( 5 + cop(p,k0) + cop(p,k1) + cop(p,k2) );
            case 10:
                return Log( 5 ) - Log( 5 + sip(p,k0) + sip(p,k1) + sip(p,k2) );
            case 11:
                return Log( 9 ) - Log( sip(p,k3m) + sip(p,k4m) + sip(p,k5m) +
                                       sip(p,k6m) + sip(p,k7m) + sip(p,k8m) + 9 );
            case 12:
                return Log( 3 ) - Log( 2 - Cos( p.y * Sqrt(3) ) );
            case 13:
                return -Log( 1 + Cos(p.x)/3 + Cos(p.y)/3 );
            case 14:
                return -Log( 1 + psqueeze3(Cos(p.x))/3 + psqueeze3(Cos(p.y))/3 );
            default:
                return -Log( 1 + psqueeze5(Cos(p.x))/3 + psqueeze5(Cos(p.y))/3 );
        }
    }

    private Vector2 confun_grad(Vector2 p, int n)
    {
        switch (n)
        {
            case 1:
                return new Vector2( 0, 0 );
            case 2:
                return new Vector2( -Sin(p.x), 0 ) / 4;
            case 3:
                return new Vector2( -Sin(p.x)*Cos(p.y), -Cos(p.x)*Sin(p.y) ) / 4;
            case 4:
                return new Vector2( Sin(p.x)*(1-Cos(p.y)), Sin(p.y)*(1-Cos(p.x)) ) / 4;
            case 5:
                return new Vector2( Sin(p.x)*(Cos(p.y)-1), Sin(p.y)*(Cos(p.x)-1) ) / 7;
            case 6:
                return new Vector2( Sin(p.x)*(1-Pow(Cos(p.x),2)), 0 ) * ( -3f / 8 );
            case 7:
                return new Vector2( Sin(p.x)*(1-Pow(Cos(p.x),2))*Cos(p.y)*(3-Pow(Cos(p.y),2)),
                                    Sin(p.y)*(1-Pow(Cos(p.y),2))*Cos(p.x)*(3-Pow(Cos(p.x),2))  )
                                        *
                                    ( -3f / 8 );
            case 8:
                return new Vector2( 0, 0 );
            case 9:
                return new Vector2( k0.x*sip(p,k0) + k1.x*sip(p,k1) + k2.x*sip(p,k2),
                                    k0.y*sip(p,k0) + k1.y*sip(p,k1) + k2.y*sip(p,k2)  )
                                        /
                                    ( 5 + cop(p,k0) + cop(p,k1) + cop(p,k2) );
            case 10:
                return new Vector2( k0.x*cop(p,k0) + k1.x*cop(p,k1) + k2.x*cop(p,k2),
                                    k0.y*cop(p,k0) + k1.y*cop(p,k1) + k2.y*cop(p,k2)  )
                                        *
                                    (-1) / ( 5 + sip(p,k0) + sip(p,k1) + sip(p,k2) );
            case 11:
                return new Vector2( k3m.x*cop(p,k3m) + k4m.x*cop(p,k4m) + k5m.x*cop(p,k5m) +
                                    k6m.x*cop(p,k6m) + k7m.x*cop(p,k7m) + k8m.x*cop(p,k8m),
                                    k3m.y*cop(p,k3m) + k4m.y*cop(p,k4m) + k5m.y*cop(p,k5m) +
                                    k6m.y*cop(p,k6m) + k7m.y*cop(p,k7m) + k8m.y*cop(p,k8m)   )
                                        *
                                    (-1) / ( sip(p,k3m) + sip(p,k4m) + sip(p,k5m) +
                                             sip(p,k6m) + sip(p,k7m) + sip(p,k8m) + 9 );
            case 12:
                return new Vector2( 0, Sin(p.y*Sqrt(3)) )
                                        *
                                    ( -Sqrt(3) ) / ( 2 - Cos(p.y*Sqrt(3)) );
            case 13:
                return new Vector2( Sin(p.x), Sin(p.y) )
                                        /
                                    ( 3 + Cos(p.x) + Cos(p.y) );
            case 14:
                return new Vector2( Sin(p.x)*psqueeze3_d(Cos(p.x)),
                                    Sin(p.y)*psqueeze3_d(Cos(p.y))  )
                                        /
                                    ( 3 + psqueeze3(Cos(p.x)) + psqueeze3(Cos(p.y)) );
            default:
                return new Vector2( Sin(p.x)*psqueeze5_d(Cos(p.x)),
                                    Sin(p.y)*psqueeze5_d(Cos(p.y))  )
                                        /
                                    ( 3 + psqueeze5(Cos(p.x)) + psqueeze5(Cos(p.y)) );
        }
    }
    
    private float sqn( Vector2 v )
    {
        return v.x*v.x + v.y*v.y;
    }

    private float det( Vector2 u, Vector2 v )
    {
        return u.x*v.y - u.y*v.x;
    }

    private Vector2 rot_by_ang( Vector2 v, float a )
    {
        float c = Cos(a);
        float s = Sin(a);

        return new Vector2( c*v.x - s*v.y, s*v.x + c*v.y );
    }

    private float distance( Vector2 p, Vector2 q, int n )
    {
        Vector2  diff  =  reset_to_fundamental_domain( p - q, domainParameters );
        return diff.magnitude * Exp( 0.5f*(confun(p,n)+confun(q,n)) );
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

    private void propagate_rocket(ref Vector4 rp, float dt, int n)
    {
        Vector2 rp_p = new Vector2(rp.x, rp.y);
        Vector2 rp_v = new Vector2(rp.z, rp.w);

        apply_geodesic_step__midpoint( ref rp_p, ref rp_v, dt, n );

        rp = new Vector4(rp_p.x, rp_p.y, rp_v.x, rp_v.y);
    }

    private Vector2 move2vel(Vector2 pos, Vector2 moveVec, float camAng, float speed)
    {
        float a = camAng * deg2rad;

        return rot_by_ang( moveVec, a ) * ( Exp( -confun( pos, metricNumber ) ) * (-speed) );
    }

    private Vector2 reset_to_domain_unit_square(Vector2 p)
    {
        return new Vector2( p.x - RoundToInt(p.x), p.y - RoundToInt(p.y) );
    }

    private Vector2 reset_to_fundamental_domain(Vector2 p, DomainParameters DP )
    {
        p = new Vector2(p.x * DP.av.x + p.y * DP.av.y, p.y * DP.bv.x + p.y * DP.bv.y);
        p = reset_to_domain_unit_square(p);
        return DP.va * p.x + DP.vb * p.y;
    }

    private void update_fps()
    {
        time += Time.deltaTime;
        frameCount++;

        if (time > pollingTime)
        {
            int frameRate = RoundToInt(frameCount / time);
            frameRateField.text = frameRate.ToString();

            time -= pollingTime;
            frameCount = 0;
        }
    }

    private void update_vision_settings()
    {
        if (incrAccuracy.WasPressedThisFrame()) accuracy *= 2;
        if (decrAccuracy.WasPressedThisFrame()) if (accuracy > 1) accuracy /= 2;

        if (incrVisRad.WasPressedThisFrame()) visionRadius *= Exp(Log(2) / 4);
        if (decrVisRad.WasPressedThisFrame()) visionRadius /= Exp(Log(2) / 4);

        if (nextGSM.WasPressedThisFrame()) if (gsmNumber < 3) gsmNumber += 1;
        if (prevGSM.WasPressedThisFrame()) if (gsmNumber > 1) gsmNumber -= 1;

        if (nextCT.WasPressedThisFrame()) if (ctNumber < 3) ctNumber += 1;
        if (prevCT.WasPressedThisFrame()) if (ctNumber > 1) ctNumber -= 1;

        if (toggleFullscreenRendering.WasPressedThisFrame()) { fullscreen = !fullscreen; if (fullscreen) fullscreenFloat = 1f; else fullscreenFloat = 0f; }
        if (toggleDisplayRoads.WasPressedThisFrame()) { displayRoads = !displayRoads; if (displayRoads) displayRoadsFloat = 1f; else displayRoadsFloat = 0f; }

        material.SetFloat( "_VisRad",     visionRadius      );
        material.SetFloat( "_Accuracy",   accuracy          );
        material.SetFloat( "_GSM",        gsmNumber         );
        material.SetFloat( "_ChartType",  ctNumber          );
        material.SetFloat( "_FullScreen", fullscreenFloat   );
        material.SetFloat( "_Roads",      displayRoadsFloat );

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
    }

    private void update_world_settings()
    {
        bool metricChanged  = false;
        bool textureChanged = false;

        if( nextMetric.WasPressedThisFrame()  ){ if( metricNumber  < 13 )  metricNumber += 1; else  metricNumber =  1;  metricChanged = true; }
        if( prevMetric.WasPressedThisFrame()  ){ if( metricNumber  >  1 )  metricNumber -= 1; else  metricNumber = 13;  metricChanged = true; }
        if( nextTexture.WasPressedThisFrame() ){ if( textureNumber <  4 ) textureNumber += 1; else textureNumber =  1; textureChanged = true; }
        if( prevTexture.WasPressedThisFrame() ){ if( textureNumber >  1 ) textureNumber -= 1; else textureNumber =  4; textureChanged = true; }

        if( metricChanged )
        {
            switch( metricNumber )
            {
                case 1:
                    metricName  =  "sqFlat";
                    domainName  =  "square";
                    domainParameters  =  make_domain_parameters( 2*PI, 2*PI, 90 );
                    break;
                case 2:
                    metricName  =  "torusPsi";
                    domainName  =  "square";
                    domainParameters  =  make_domain_parameters( 2*PI, 2*PI, 90 );
                    break;
                case 3:
                    metricName  =  "dgBump";
                    domainName  =  "square";
                    domainParameters  =  make_domain_parameters( 2*PI, 2*PI, 90 );
                    break;
                case 4:
                    metricName  =  "sqBump";
                    domainName  =  "square";
                    domainParameters  =  make_domain_parameters( 2*PI, 2*PI, 90 );
                    break;
                case 5:
                    metricName  =  "sqAntiBump";
                    domainName  =  "square";
                    domainParameters  =  make_domain_parameters( 2*PI, 2*PI, 90 );
                    break;
                case 6:
                    metricName  =  "torusPsiSqz";
                    domainName  =  "square";
                    domainParameters  =  make_domain_parameters( 2*PI, 2*PI, 90 );
                    break;
                case 7:
                    metricName  =  "dgBumpSqz";
                    domainName  =  "square";
                    domainParameters  =  make_domain_parameters( 2*PI, 2*PI, 90 );
                    break;
                case 8:
                    metricName  =  "hexFlat";
                    domainName  =  "hexagon";
                    domainParameters  =  make_domain_parameters( 2*PI, 2*PI, 60 );
                    break;
                case 9:
                    metricName  =  "hexBump";
                    domainName  =  "hexagon";
                    domainParameters  =  make_domain_parameters( 2*PI, 2*PI, 60 );
                    break;
                case 10:
                    metricName  =  "hexRump";
                    domainName  =  "hexagon";
                    domainParameters  =  make_domain_parameters( 2*PI, 2*PI, 60 );
                    break;
                case 11:
                    metricName  =  "hexp3";
                    domainName  =  "hexagon";
                    domainParameters  =  make_domain_parameters( 4*PI, 4*PI, 60 );
                    break;
                case 12:
                    metricName  =  "torus";
                    domainName  =  "rectangle";
                    domainParameters  =  make_domain_parameters( 2*PI, 2*PI/Sqrt(3), 90 );
                    break;
                case 13:
                    metricName  =  "dupin";
                    domainName  =  "square";
                    domainParameters  =  make_domain_parameters( 2*PI, 2*PI, 90 );
                    break;
                case 14:
                    metricName  =  "dupinSqz3";
                    domainName  =  "square";
                    domainParameters  =  make_domain_parameters( 2*PI, 2*PI, 90 );
                    break;
                default:
                    metricName  =  "dupinSqz5";
                    domainName  =  "square";
                    domainParameters  =  make_domain_parameters( 2*PI, 2*PI, 90 );
                    break;
            }

            material.shader  =  Shader.Find( "Custom/Confmets/" + metricName );
            metricField.text  =  metricName;
            domainField.text  =  domainName;

            Vector4  domMat  =  new Vector4( domainParameters.va.x, domainParameters.vb.x, domainParameters.va.y, domainParameters.vb.y );
            material.SetVector( "_DomMat", domMat );
        }

        if( textureChanged ) textureField.text = textureNumber.ToString();

        if( metricChanged | textureChanged )
        {
            tilingTexture  =  AssetDatabase.LoadAssetAtPath<Texture2D>( "Assets/Textures/Tilings/" + metricName + "_" + textureNumber.ToString() + ".png" );
            material.SetTexture( "_BaseMap", tilingTexture );
        }
    }

    private void update_rocket_states()
    {
        if (shoot.WasPressedThisFrame())
        {
            rocketsLive[nextRocket] = rocketInitialLive;
            rocketsState[nextRocket] = material.GetVector("_CamPos");

            float rsf = rocketSpeed * Exp(-confun(new Vector2(rocketsState[nextRocket].x, rocketsState[nextRocket].y), metricNumber));

            rocketsState[nextRocket].z *= rsf;
            rocketsState[nextRocket].w *= rsf;

            nextRocket++;
            if (nextRocket > 15)
                nextRocket = 0;
        }
    }

    private void update_vulture()
    {
        moveVulture  =  moveAction.ReadValue<Vector2>();

        vulture.state.vel  = 
            move2vel( vulture.state.pos, moveVulture,
                        vulture.state.ang, vulture.props.speed );

        float  dt  =  Time.deltaTime;
        float  da  =  0.0f;

        if( vulture.state.vel.magnitude > 0 )
        {
            Vector2  accel  =
                -christoffel( vulture.state.pos, vulture.state.vel,
                    vulture.state.vel, metricNumber );

            da  =  dt * det( accel, vulture.state.vel ) / sqn( vulture.state.vel );

            vulture.state.tan  =  vulture.state.vel.normalized;
        }

        if( stopVul.ReadValue<float>() == 0 )
        {
            vulture.state.pos  =  reset_to_fundamental_domain( vulture.state.pos + dt*vulture.state.vel, domainParameters );

            vulture.state.ang  =  vulture.state.ang - da*rad2deg;
        }

        vulture.state.nor  =  rot_by_ang( vulture.state.tan, PI/2 );

        material.SetVector( "_CamPos", new Vector4( vulture.state.pos.x, vulture.state.pos.y, vulture.state.tan.x, vulture.state.tan.y ) );
        material.SetFloat(  "_CamAng", vulture.state.ang );
    }

    private void update_rockets()
    {
        for( int k = 0; k < 16; k++ )
        {
            propagate_rocket( ref rocketsState[k], Time.deltaTime, metricNumber );
            if( rocketsLive[k] > 0 )
                rocketsLive[k] -= Time.deltaTime;
        }
    }

    private void detect_vulture_rocket_collisions()
    {
        Vector4  camPos  =  material.GetVector( "_CamPos" );

        for( int k = 0; k < 16; k++ )
        {
            Vector2  p  =  new Vector2( rocketsState[k].x, rocketsState[k].y );
            Vector2  q  =  new Vector2( camPos.x,          camPos.y          );

            float  dist  =  distance( p, q, metricNumber );

            if( dist < 0.35f )
                if( rocketsLive[k] < 3f )
                    rocketsLive[k] = 0f;
        }
    }
    
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

        nextCT = InputSystem.actions.FindAction("Next Chart Type");
        prevCT = InputSystem.actions.FindAction("Previous Chart Type");

        incrAccuracy = InputSystem.actions.FindAction("Increase Accuracy");
        decrAccuracy = InputSystem.actions.FindAction("Decrease Accuracy");

        incrVisRad = InputSystem.actions.FindAction("Increase Vision Radius");
        decrVisRad = InputSystem.actions.FindAction("Decrease Vision Radius");

        stopVul = InputSystem.actions.FindAction("Stop");

        shoot = InputSystem.actions.FindAction("Attack");

        toggleFullscreenRendering = InputSystem.actions.FindAction("Toggle Fullscreen Rendering");
        toggleDisplayRoads = InputSystem.actions.FindAction("Toggle Display Roads");

        domainParameters = make_domain_parameters(2 * PI, 2 * PI, 90);

        tilingTexture = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Textures/Tilings/" + metricName + "_" + textureNumber.ToString() + ".png");
        material.SetTexture("_BaseMap", tilingTexture);

        vulture.state.pos  =  new Vector2( 0.0f, 0.0f );
        vulture.state.vel  =  new Vector2( 0.0f, 0.0f );
        vulture.state.tan  =  new Vector2( 1.0f, 0.0f );
        vulture.state.nor  =  new Vector2( 0.0f, 1.0f );
        vulture.state.ang  =  0.0f;
        vulture.state.sgn  =  1.0f;

        vulture.props.speed  =  vultureMoveSpeed;

    }

    private void Start()
    {
    }

    private void Update()
    {
        update_fps();
        update_vision_settings();
        update_world_settings();
        update_rocket_states();
    }

    private void FixedUpdate()
    {
        update_vulture();
        update_rockets();
        detect_vulture_rocket_collisions();

        material.SetVectorArray("_RocketsState", rocketsState);
        material.SetFloatArray("_RocketsLive", rocketsLive);
    }
}
