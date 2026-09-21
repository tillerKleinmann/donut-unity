using UnityEngine;
using static UnityEngine.Mathf;
using UnityEditor;
using UnityEngine.InputSystem;
using TMPro;

public class ScreenScript : MonoBehaviour
{
    private Texture2D tilingTexture, spaceTexture;

    public InputActionAsset InputActions;

    public float vultureMoveSpeed, visionRadius, rocketSpeed, rocketInitialLive;

    public int accuracy, metricNumber, textureNumber, gsmNumber, roadsType;

    public int metricCount, textureCount, roadsTypeCount;

    private InputAction moveAction, nextMetric, prevMetric, incrVisRad, decrVisRad, incrAccuracy, decrAccuracy, nextTexture, prevTexture, nextRoadsType, prevRoadsType, nextGSM, prevGSM, nextCT, prevCT, stopVul, shoot, toggleFullscreenRendering, toggleDisplayRoads, resetVulPos;

    private Vector2 moveVulture;


    private Vector2 vulPos, vulVel, vulTan, vulNor;

    private float   a1, a2, a3, a4, a5, a6;
    private Vector2 k1, k2, k3, k4, k5, k6;

    private Vector4[] rocketsState = new Vector4[16];
    private float[] rocketsLive = new float[16];
    private int nextRocket = 0;

    private int ctNumber = 1;

    private static float rad2deg_factor = 180/PI;
    private float deg2rad( float al_deg ){ return al_deg * deg2rad_factor; }
    private static float deg2rad_factor = PI/180;
    private float rad2deg( float al_rad ){ return al_rad * rad2deg_factor; }

    private string metricName = "tp_flat";
    private string domainName = "square";

    public TextMeshProUGUI domainField, metricField, textureField, radiusField, GSMField, accuracyField, frameRateField;

    private float pollingTime = 1f, time = 0f;
    private int frameCount = 0;

    private bool fullscreen = false;
    private bool displayRoads = false;

    private float fullscreenFloat = 0f, displayRoadsFloat = 0f;

    Material material;

    private struct ObjState
    {
        public Vector2 pos; // Position (vector)
        public Vector2 vel; // Velocity (vector)
        public Vector2 tan; // Tangent Vector (normalized vector)
        public Vector2 nor; // Normal Vector (normalized vector, for immersed surfaces: binormal vector in the Darboux frame)
        public float ang; // Angle (real number, relative to the standard x-coordinate vector)
        public float sgn; // Sign (can be +1 or -1, means orientation)
    }

    private struct Vulture
    {
        public ObjState state;
        public float moveSpeed;
    }

    private struct Observer
    {
        public ObjState state;
    }

    private Vulture vulture;
    private Observer observer;

    private struct FundamentalDomain
    {
        public float w;
        public float h;
        public float s;

        public float lu;
        public float lv;

        public float ga_deg;
        public float ga;

        public Vector2 Lu;
        public Vector2 Lv;

        public Vector2 Ku;
        public Vector2 Kv;
    }

    private FundamentalDomain fuDo;

    private void complete_fuDo_from_whs()
    {
        fuDo.lu  =  fuDo.w;
        fuDo.lv  =  Sqrt( Pow(fuDo.h,2) + Pow(fuDo.s,2) );

        fuDo.ga  =  Asin( fuDo.h / fuDo.lv );

        fuDo.ga_deg  =  rad2deg( fuDo.ga );

        fuDo.Lu  =  new Vector2( fuDo.w,      0 );
        fuDo.Lv  =  new Vector2( fuDo.s, fuDo.h );

        fuDo.Ku  =  new Vector2( 1 / fuDo.w, -fuDo.s / ( fuDo.w * fuDo.h ) );
        fuDo.Kv  =  new Vector2(          0,                    1 / fuDo.h );
    }

    private void set_fuDo_l1l2ga_deg( float lu, float lv, float ga_deg )
    {
        fuDo.ga  =  deg2rad( ga_deg );

        fuDo.w  =  lu;
        fuDo.h  =  lv * Sin( fuDo.ga );
        fuDo.s  = -lv * Cos( fuDo.ga );

        complete_fuDo_from_whs();
    }

    private void set_fuDo( float w, float h, float s )
    {
        fuDo.w  =  w;
        fuDo.h  =  h;
        fuDo.s  =  s;

        complete_fuDo_from_whs();
    }

    private void set_fuDo_hexagon( float w )
    {
        fuDo.w  =  w;
        fuDo.h  =  w * (Sqrt(3)/2);
        fuDo.s  =  w / 2;

        complete_fuDo_from_whs();
    }

    private void set_fuDo_square( float w )
    {
        fuDo.w  =  w;
        fuDo.h  =  w;
        fuDo.s  =  0;

        complete_fuDo_from_whs();
    }

    private void set_fuDo_rectangle( float lu, float lv )
    {
        fuDo.w  =  lu;
        fuDo.h  =  lv;
        fuDo.s  =  0;

        complete_fuDo_from_whs();
    }

    private void set_fuDo_centered( float w, float h )
    {
        fuDo.w  =  w;
        fuDo.h  =  h;
        fuDo.s  =  w / 2;

        complete_fuDo_from_whs();
    }

    private Vector2 dual_lattice_vector( int k, int l )
    {
        return new Vector2( k / fuDo.w, l / fuDo.h  -  k * (fuDo.s/(fuDo.w*fuDo.h)) ) * 2*PI;
    }

    private Vector2 rot180( Vector2 p ){ return new Vector2( -p.x, -p.y ); }
    private Vector2 rot90(  Vector2 p ){ return new Vector2( -p.y,  p.x ); }
    private Vector2 rot270( Vector2 p ){ return new Vector2(  p.y, -p.x ); }
    private Vector2 rot120( Vector2 p ){ return new Vector2( -0.5f*p.x - Sqrt(0.75f)*p.y, -0.5f*p.y + Sqrt(0.75f)*p.x ); }
    private Vector2 rot240( Vector2 p ){ return new Vector2( -0.5f*p.x + Sqrt(0.75f)*p.y, -0.5f*p.y - Sqrt(0.75f)*p.x ); }
    private Vector2 rot60(  Vector2 p ){ return new Vector2(  0.5f*p.x - Sqrt(0.75f)*p.y,  0.5f*p.y + Sqrt(0.75f)*p.x ); }
    private Vector2 rot300( Vector2 p ){ return new Vector2(  0.5f*p.x + Sqrt(0.75f)*p.y,  0.5f*p.y - Sqrt(0.75f)*p.x ); }

    private float skap( Vector2 p, Vector2 k ){ return p.x*k.x + p.y*k.y; }

    private float cop( Vector2 p, Vector2 k ){ return Cos(skap(k,p)); }
    private float sip( Vector2 p, Vector2 k ){ return Sin(skap(k,p)); }

    private float cop_dx( Vector2 p, Vector2 k ){ return -sip(k,p)*k.x; }
    private float sip_dx( Vector2 p, Vector2 k ){ return  cop(k,p)*k.x; }

    private float cop_dy( Vector2 p, Vector2 k ){ return -sip(k,p)*k.y; }
    private float sip_dy( Vector2 p, Vector2 k ){ return  cop(k,p)*k.y; }

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

    private float confun( Vector2 p )
    {
        switch( metricName )
        {
            default:
                return 0f;
            case "tp_flat":
                return 0f;
            case "hp_flat":
                return 0f;
            case "mp_flat":
                return 0f;
            case "op_flat":
                return 0f;
            case "oc_flat":
                return 0f;
            case "torus":
                return  Log(3) - Log( 2 + Cos(p.y*a1) );
            case "torusPsi":
                return  -Cos(p.y*a1) / 4;
            case "torusPsiSqz":
                return  0.5f - Cos(p.y*a1)*(3-Pow(Cos(p.y*a1),2))/8;
            case "dgBump":
                return  Cos(p.x)*Cos(p.y) / 4;
            case "dgBumpSqz":
                return  ( 4 + Cos(p.x)*(3-Pow(Cos(p.x),2))*Cos(p.y)*(3-Pow(Cos(p.y),2)) ) / 8;
            case "sqBump":
                return  (1-Cos(p.x))*(1-Cos(p.y)) / 4;
            case "sqAntiBump":
                return  ( 2 - (1-Cos(p.x))*(1-Cos(p.y)) ) / 7;
            case "tp_p4":
                return  Log(6) - Log( 6 + Cos(p.x) + Cos(p.y) + Cos( p.x + p.y/2 ) + Cos( -p.x/2 + p.y ) );
            case "dupin": // p4m
                return  Log(3) - Log( 3 + Cos(p.x) + Cos(p.y) );
            case "dupinSqz3":
                return  Log(3) - Log( 3 + psqueeze3(Cos(p.x)) + psqueeze3(Cos(p.y)) );
            case "dupinSqz5":
                return  Log(3) - Log( 3 + psqueeze5(Cos(p.x)) + psqueeze5(Cos(p.y)) );
            case "tp_p4g":
                return  Log(5) - Log( 5 + Cos(p.x/2)*Cos(p.y/2) + Sin(p.x/2)*Sin(p.y) - Sin(p.x)*Sin(p.y/2) );
            case "hp_p3":
                return  Log(9) - Log( 9 + sip(p,k1) + sip(p,k2) + sip(p,k3) + sip(p,k4) + sip(p,k5) + sip(p,k6) );
            case "hp_p31m":
                return  Log(8) - Log( 8 + 2*Sin(p.x*a1)*Cos(p.y*a2) - Sin(p.x*a3) + 2*Cos(p.x*a4)*Cos(p.y*a5) + Cos(p.y*a6) );
            case "hp_p3m1":
                return  Log(5) - Log( 5 + sip(p,k1) + sip(p,k2) + sip(p,k3) );
            case "hp_p6":
                return  Log(9) - Log( 9 + cop(p,k1) + cop(p,k2) + cop(p,k3) + cop(p,k4) + cop(p,k5) + cop(p,k6) );
            case "hp_p6m":
                return  Log(5) - Log( 5 + cop(p,k1) + cop(p,k2) + cop(p,k3) );
        }
    }

    private Vector2 confun_grad( Vector2 p )
    {
        switch( metricName )
        {
            default:
                return new Vector2( 0f, 0f );
            case "tp_flat":
                return new Vector2( 0f, 0f );
            case "hp_flat":
                return new Vector2( 0f, 0f );
            case "mp_flat":
                return new Vector2( 0f, 0f );
            case "op_flat":
                return new Vector2( 0f, 0f );
            case "oc_flat":
                return new Vector2( 0f, 0f );
            case "torus":
                return new Vector2( 0f, Sin(p.y*a1) * a1 / ( 2 + Cos(p.y*a1) ) );
            case "torusPsi":
                return new Vector2( 0f, a1 * Sin(p.y*a1) / 4 );
            case "torusPsiSqz":
                return new Vector2( 0f, a1 * Sin(p.y*a1)*(1-Pow(Cos(p.y*a1),2)) * (3f/8) );
            case "dgBump":
                return new Vector2( -Sin(p.x)*Cos(p.y), -Cos(p.x)*Sin(p.y) ) / 4;
            case "dgBumpSqz":
                return new Vector2( Sin(p.x)*(1-Pow(Cos(p.x),2))*Cos(p.y)*(3-Pow(Cos(p.y),2)),
                                    Sin(p.y)*(1-Pow(Cos(p.y),2))*Cos(p.x)*(3-Pow(Cos(p.x),2))  ) * (-3f/8);
            case "sqBump":
                return new Vector2( Sin(p.x)*(1-Cos(p.y)), Sin(p.y)*(1-Cos(p.x)) ) / 4;
            case "sqAntiBump":
                return new Vector2( Sin(p.x)*(Cos(p.y)-1), Sin(p.y)*(Cos(p.x)-1) ) / 7;
            case "tp_p4":
                return new Vector2( Sin(p.x) + Sin(p.x+p.y/2) - Sin(-p.x/2+p.y)/2,
                                    Sin(p.y) + Sin( p.x + p.y/2 )/2 + Sin( -p.x/2 + p.y ) )
                                        /
                                    ( 6 + Cos(p.x) + Cos(p.y) + Cos( p.x + p.y/2 ) + Cos( -p.x/2 + p.y ) );
            case "dupin":// p4m
                return new Vector2( Sin(p.x), Sin(p.y) ) / ( 3 + Cos(p.x) + Cos(p.y) );
            case "dupinSqz3":
                return new Vector2( Sin(p.x)*psqueeze3_d(Cos(p.x)),
                                    Sin(p.y)*psqueeze3_d(Cos(p.y))  )
                                        /
                                    ( 3 + psqueeze3(Cos(p.x)) + psqueeze3(Cos(p.y)) );
            case "dupinSqz5":
                return new Vector2( Sin(p.x)*psqueeze5_d(Cos(p.x)),
                                    Sin(p.y)*psqueeze5_d(Cos(p.y))  )
                                        /
                                    ( 3 + psqueeze5(Cos(p.x)) + psqueeze5(Cos(p.y)) );
            case "tp_p4g":
                return new Vector2( Sin(p.x/2)*Cos(p.y/2)/2 - Cos(p.x/2)*Sin(p.y)/2 + Cos(p.x)*Sin(p.y/2),
                                    Cos(p.x/2)*Sin(p.y/2)/2 - Sin(p.x/2)*Cos(p.y)   + Sin(p.x)*Cos(p.y/2)/2 )
                                        /
                                    ( 5 + Cos(p.x/2)*Cos(p.y/2) + Sin(p.x/2)*Sin(p.y) - Sin(p.x)*Sin(p.y/2) );
            case "hp_p3":
                return new Vector2( sip_dx(p,k1) + sip_dx(p,k2) + sip_dx(p,k3) + sip_dx(p,k4) + sip_dx(p,k5) + sip_dx(p,k6),
                                    sip_dy(p,k1) + sip_dy(p,k2) + sip_dy(p,k3) + sip_dy(p,k4) + sip_dy(p,k5) + sip_dy(p,k6)  )
                                        /
                                    -( 9 + sip(p,k1) + sip(p,k2) + sip(p,k3) + sip(p,k4) + sip(p,k5) + sip(p,k6) );
            case "hp_p31m":
                return new Vector2( 2*a4*Sin(p.x*a4)*Cos(p.y*a5)                  - 2*a1*Cos(p.x*a1)*Cos(p.y*a2) + a3*Cos(p.x*a3),
                                    2*a5*Cos(p.x*a4)*Sin(p.y*a5) + a6*Sin(p.y*a6) + 2*a2*Sin(p.x*a1)*Sin(p.y*a2)                   )
                                        /
                                    ( 8 + 2*Cos(p.x*a4)*Cos(p.y*a5) + Cos(p.y*a6) + 2*Sin(p.x*a1)*Cos(p.y*a2) - Sin(p.x*a3) );
            case "hp_p3m1":
                return new Vector2( sip_dx(p,k1) + sip_dx(p,k2) + sip_dx(p,k3),
                                    sip_dy(p,k1) + sip_dy(p,k2) + sip_dy(p,k3)  )
                                        /
                                    -( 5 + sip(p,k1) + sip(p,k2) + sip(p,k3) );
            case "hp_p6":
                return new Vector2( cop_dx(p,k1) + cop_dx(p,k2) + cop_dx(p,k3) + cop_dx(p,k4) + cop_dx(p,k5) + cop_dx(p,k6),
                                    cop_dy(p,k1) + cop_dy(p,k2) + cop_dy(p,k3) + cop_dy(p,k4) + cop_dy(p,k5) + cop_dy(p,k6)  )
                                        /
                                    -( 9 + cop(p,k1) + cop(p,k2) + cop(p,k3) + cop(p,k4) + cop(p,k5) + cop(p,k6) );
            case "hp_p6m":
                return new Vector2( cop_dx(p,k1) + cop_dx(p,k2) + cop_dx(p,k3),
                                    cop_dy(p,k1) + cop_dy(p,k2) + cop_dy(p,k3)  )
                                        /
                                    -( 5 + cop(p,k1) + cop(p,k2) + cop(p,k3) );
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

    private Vector2 rotate_by_angle( Vector2 v, float a )
    {
        float c = Cos(a);
        float s = Sin(a);

        return new Vector2( c*v.x - s*v.y, s*v.x + c*v.y );
    }

    private Vector2 rotate_by_90( Vector2 v )
    {
        return new Vector2( -v.y, v.x );
    }

    private float distance( Vector2 p, Vector2 q )
    {
        Vector2  diff  =  reset_to_fundamental_domain( p - q );
        return diff.magnitude * Exp( 0.5f*( confun(p) + confun(q) ) );
    }

    private Vector2 christoffel( Vector2 p, Vector2 u, Vector2 v )
    {
        Vector2 cfd  =  confun_grad( p );

        float a  =  u.x*v.x - u.y*v.y;
        float b  =  u.x*v.y + u.y*v.x;

        return new Vector2( cfd.x*a + cfd.y*b, -cfd.y*a + cfd.x*b );
    }

    private Vector2 parallel_transport_step__euler(Vector2 x, Vector2 dx, Vector2 y, float dt)
    {
        return y - dt*christoffel( x, dx, y );
    }

    private void apply_geodesic_step__euler(ref Vector2 p, ref Vector2 v, float dt)
    {
        Vector2 Ga = christoffel( p, v, v );

        p += dt*v;
        v -= dt*Ga;
    }

    private void apply_geodesic_step__midpoint( ref Vector2 p, ref Vector2 v, float dt )
    {
        Vector2 Ga  =  christoffel( p, v, v );

        Vector2 p_m  =  p + (dt/2)*v;
        Vector2 v_m  =  v - (dt/2)*Ga;

        Vector2 Ga_m  =  christoffel( p_m, v_m, v_m );

        p  =  p + dt*v_m;
        v  =  v - dt*Ga_m;
    }

    private void propagate_rocket( ref Vector4 rp, float dt )
    {
        Vector2  rp_p  =  new Vector2( rp.x, rp.y );
        Vector2  rp_v  =  new Vector2( rp.z, rp.w );

        apply_geodesic_step__midpoint( ref rp_p, ref rp_v, dt );

        rp  =  new Vector4( rp_p.x, rp_p.y, rp_v.x, rp_v.y );
    }

    private Vector2 move2vel( Vector2 pos, Vector2 moveVec, float camAng_deg, float speed )
    {
        return rotate_by_angle( moveVec, deg2rad(camAng_deg) ) * ( Exp( -confun( pos ) ) * speed );
    }

    private Vector2 reset_to_domain_unit_square( Vector2 p )
    {
        return new Vector2( p.x - RoundToInt(p.x), p.y - RoundToInt(p.y) );
    }

    private Vector2 dom2usq( Vector2 p )
    {
        return new Vector2( p.x*fuDo.Ku.x + p.y*fuDo.Ku.y, p.y*fuDo.Kv.x + p.y*fuDo.Kv.y );
    }

    private Vector2 usq2dom( Vector2 q )
    {
        return  fuDo.Lu*q.x + fuDo.Lv*q.y;
    }

    private Vector2 reset_to_fundamental_domain( Vector2 p )
    {
        return  p  =  usq2dom( reset_to_domain_unit_square( dom2usq( p ) ) );
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

        material.SetFloat( "_ChartType",  ctNumber          );
        material.SetFloat( "_RoadsDisp",  displayRoadsFloat );
        material.SetFloat( "_RoadsType",  (float)roadsType  );
        material.SetFloat( "_VisRad",     visionRadius      );
        material.SetFloat( "_FullScreen", fullscreenFloat   );
        material.SetFloat( "_Accuracy",   accuracy          );
        material.SetFloat( "_GSM",        gsmNumber         );

        accuracyField.text = accuracy.ToString();
        radiusField.text = string.Format("{0:0.000}", visionRadius);

        switch( gsmNumber )
        {
            default:    GSMField.text = "RK4";      break;
            case 2:     GSMField.text = "midp";     break;
            case 3:     GSMField.text = "euler";    break;
        }
    }

    private void update_world_settings()
    {
        bool metricChanged  = false;
        bool textureChanged = false;

        if( nextMetric.WasPressedThisFrame()  ){ if( metricNumber  < metricCount )  metricNumber += 1; else  metricNumber =  1;           metricChanged = true; }
        if( prevMetric.WasPressedThisFrame()  ){ if( metricNumber  >  1 )           metricNumber -= 1; else  metricNumber = metricCount;  metricChanged = true; }
        
        if( nextTexture.WasPressedThisFrame() ){ if( textureNumber <  textureCount ) textureNumber += 1; else textureNumber =  1;           textureChanged = true; }
        if( prevTexture.WasPressedThisFrame() ){ if( textureNumber >  1 )            textureNumber -= 1; else textureNumber = textureCount; textureChanged = true; }
        
        if( nextRoadsType.WasPressedThisFrame() ){ if( roadsType <  roadsTypeCount ) roadsType += 1; else roadsType = 1;              }
        if( prevRoadsType.WasPressedThisFrame() ){ if( roadsType >  1 )              roadsType -= 1; else roadsType = roadsTypeCount; }

        if( metricChanged )
        {
            switch( metricNumber )
            {
                default:    metricName  =  "tp_flat";       break;
                case 1:     metricName  =  "tp_flat";       break;
                case 2:     metricName  =  "op_flat";       break;
                case 3:     metricName  =  "hp_flat";       break;
                case 4:     metricName  =  "oc_flat";       break;
                case 5:     metricName  =  "mp_flat";       break;
                case 6:     metricName  =  "torus";         break;
                case 7:     metricName  =  "torusPsi";      break;
                case 8:     metricName  =  "torusPsiSqz";   break;
                case 9:     metricName  =  "dgBump";        break;
                case 12:    metricName  =  "dgBumpSqz";     break;
                case 10:    metricName  =  "sqBump";        break;
                case 11:    metricName  =  "sqAntiBump";    break;
                case 13:    metricName  =  "tp_p4";         break;
                case 14:    metricName  =  "dupin";         break;
                case 15:    metricName  =  "dupinSqz3";     break;
                case 16:    metricName  =  "dupinSqz5";     break;
                case 17:    metricName  =  "tp_p4g";        break;
                case 18:    metricName  =  "hp_p3";         break;
                case 19:    metricName  =  "hp_p31m";       break;
                case 20:    metricName  =  "hp_p3m1";       break;
                case 21:    metricName  =  "hp_p6";         break;
                case 22:    metricName  =  "hp_p6m";        break;
            }

            switch( metricName )
            {
                default:
                    domainName  =  "square";
                    roadsType  =  11;
                    set_fuDo_square( 2*PI );
                    break;
                case "tp_flat":
                    domainName  =  "square";
                    roadsType  =  11;
                    set_fuDo_square( 2*PI );
                    break;
                case "hp_flat":
                    domainName  =  "hexagon";
                    roadsType  =  17;
                    set_fuDo_hexagon( 2*PI );
                    break;
                case "mp_flat":
                    domainName  =  "oblique";
                    roadsType  =  1;
                    set_fuDo( 2*PI, 2*PI, 2*PI/3 );
                    break;
                case "op_flat":
                    domainName  =  "rectangle";
                    roadsType  =  1;
                    set_fuDo_rectangle( 2*PI, 3*PI );
                    break;
                case "oc_flat":
                    domainName  =  "centered";
                    roadsType  =  1;
                    set_fuDo_centered( 2*PI, 2*PI );
                    break;
                case "torus":
                    domainName  =  "rectangle";
                    roadsType  =  7;
                    set_fuDo_rectangle( 2*PI, 2*PI/Sqrt(3) );
                    a1  =  2*PI / fuDo.h;
                    break;
                case "torusPsi":
                    domainName  =  "square";
                    roadsType  =  7;
                    set_fuDo_square( 2*PI );
                    a1  =  2*PI / fuDo.h;
                    break;
                case "torusPsiSqz":
                    domainName  =  "square";
                    roadsType  =  7;
                    set_fuDo_square( 2*PI );
                    a1  =  2*PI / fuDo.h;
                    break;
                case "dgBump":
                    domainName  =  "square";
                    roadsType  =  11;
                    set_fuDo_square( 2*PI );
                    break;
                case "dgBumpSqz":
                    domainName  =  "square";
                    roadsType  =  11;
                    set_fuDo_square( 2*PI );
                    break;
                case "sqBump":
                    domainName  =  "square";
                    roadsType  =  11;
                    set_fuDo_square( 2*PI );
                    break;
                case "sqAntiBump":
                    domainName  =  "square";
                    roadsType  =  11;
                    set_fuDo_square( 2*PI );
                    break;
                case "tp_p4":
                    domainName  =  "square";
                    roadsType  =  10;
                    set_fuDo_square( 4*PI );
                    break;
                case "dupin":
                    domainName  =  "square";
                    roadsType  =  11;
                    set_fuDo_square( 2*PI );
                    break;
                case "dupinSqz3":
                    domainName  =  "square";
                    roadsType  =  11;
                    set_fuDo_square( 2*PI );
                    break;
                case "dupinSqz5":
                    domainName  =  "square";
                    roadsType  =  11;
                    set_fuDo_square( 2*PI );
                    break;
                case "tp_p4g":
                    domainName  =  "square";
                    roadsType  =  12;
                    set_fuDo_square( 4*PI );
                    break;
                case "hp_p3":
                    domainName  =  "hexagon";
                    roadsType  =  13;
                    set_fuDo_hexagon( 4*PI );
                    k1  =  dual_lattice_vector( 2, 0 );
                    k2  =  rot120( k1 );
                    k3  =  rot240( k1 );
                    k4  =  dual_lattice_vector( 2, 1 );
                    k5  =  rot120( k4 );
                    k6  =  rot240( k4 );
                    break;
                case "hp_p31m":
                    domainName  =  "hexagon";
                    roadsType  =  14;
                    set_fuDo_hexagon( 4*PI );
                    a1  =  2*PI / fuDo.w;
                    a2  =  2*PI / fuDo.w * Sqrt(3);
                    a3  =  4*PI / fuDo.w;
                    a4  =  4*PI / fuDo.w;
                    a5  =  4*PI / fuDo.w / Sqrt(3);
                    a6  =  8*PI / fuDo.w / Sqrt(3);
                    break;
                case "hp_p3m1":
                    domainName  =  "hexagon";
                    roadsType  =  15;
                    set_fuDo_hexagon( 2*PI );
                    k1  =  dual_lattice_vector( 0, 1 );
                    k2  =  rot120( k1 );
                    k3  =  rot240( k1 );
                    break;
                case "hp_p6":
                    domainName  =  "hexagon";
                    roadsType  =  16;
                    set_fuDo_hexagon( 4*PI );
                    k1  =  dual_lattice_vector( 1, 0 );
                    k2  =  rot120( k1 );
                    k3  =  rot240( k1 );
                    k4  =  dual_lattice_vector( 3, 1 );
                    k5  =  rot120( k4 );
                    k6  =  rot240( k4 );
                    break;
                case "hp_p6m":
                    domainName  =  "hexagon";
                    roadsType  =  17;
                    set_fuDo_hexagon( 2*PI );
                    k1  =  dual_lattice_vector( 0, 1 );
                    k2  =  rot120( k1 );
                    k3  =  rot240( k1 );
                    break;
            }

            material.shader  =  Shader.Find( "Custom/Confmets/" + metricName );
            metricField.text  =  metricName;
            domainField.text  =  domainName;

            material.SetVector( "_DomMat", new Vector4( fuDo.Lu.x, fuDo.Lv.x, fuDo.Lu.y, fuDo.Lv.y ) );
        }

        if( textureChanged ) textureField.text = textureNumber.ToString();

        if( metricChanged | textureChanged )
        {
            tilingTexture  =  AssetDatabase.LoadAssetAtPath<Texture2D>( "Assets/Textures/Tilings/" + metricName + "_" + textureNumber.ToString() + ".png" );
            material.SetTexture( "_BaseMap", tilingTexture );
        }
    }

    private void update_vulture_actions()
    {
        if( resetVulPos.WasPressedThisFrame() )
        {
            vulture.state.pos  =  new Vector2( 0.0f, 0.0f );
            vulture.state.vel  =  new Vector2( 0.0f, 0.0f );
            vulture.state.tan  =  new Vector2( 1.0f, 0.0f );
            vulture.state.nor  =  new Vector2( 1.0f, 1.0f );
            vulture.state.ang  =  0;
            vulture.state.sgn  =  1.0f;
        }
    }

    private void update_rocket_states()
    {
        if (shoot.WasPressedThisFrame())
        {
            rocketsLive[nextRocket] = rocketInitialLive;
            rocketsState[nextRocket] = material.GetVector("_CamPos");

            float rsf = rocketSpeed * Exp( -confun( new Vector2(rocketsState[nextRocket].x, rocketsState[nextRocket].y ) ) );

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

        vulture.state.vel  =  move2vel( vulture.state.pos, moveVulture, observer.state.ang, vulture.moveSpeed );

        float  dt  =  Time.deltaTime;
        float  da  =  0.0f;

        if( vulture.state.vel.magnitude > 0 )
        {
            Vector2  accel  =  -christoffel( vulture.state.pos, vulture.state.vel, vulture.state.vel );

            da  =  dt * det( accel, vulture.state.vel ) / sqn( vulture.state.vel );

            vulture.state.tan  =  vulture.state.vel.normalized;
        }

        if( stopVul.ReadValue<float>() == 0 )
        {
            vulture.state.pos  =  reset_to_fundamental_domain( vulture.state.pos + dt*vulture.state.vel );

            observer.state.ang  =  observer.state.ang - da*rad2deg_factor;
        }

        vulture.state.nor  =  rotate_by_90( vulture.state.tan );
    }

    private void update_rocket( int k )
    {
        propagate_rocket( ref rocketsState[k], Time.deltaTime );

        if( rocketsLive[k] > 0 )
            rocketsLive[k] -= Time.deltaTime;        
    }

    private void update_rockets()
    {
        for( int k = 0; k < 16; k++ )
            update_rocket( k );
    }

    private void detect_vulture_rocket_collisions()
    {
        for( int k = 0; k < 16; k++ )
            if( distance( new Vector2( rocketsState[k].x, rocketsState[k].y ), vulture.state.pos ) < 0.35f )
                if( rocketsLive[k] < 3f )
                    rocketsLive[k] = 0f;
    }
    
    private void Awake()
    {
        material = GetComponent<Renderer>().material;

        moveAction = InputSystem.actions.FindAction("Move");

        nextMetric = InputSystem.actions.FindAction("Next Metric");
        prevMetric = InputSystem.actions.FindAction("Previous Metric");

        nextTexture = InputSystem.actions.FindAction("Next Texture");
        prevTexture = InputSystem.actions.FindAction("Previous Texture");

        nextRoadsType = InputSystem.actions.FindAction("Next Roads Type");
        prevRoadsType = InputSystem.actions.FindAction("Previous Roads Type");

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

        resetVulPos = InputSystem.actions.FindAction("Reset Vulture Position");

        toggleFullscreenRendering = InputSystem.actions.FindAction("Toggle Fullscreen Rendering");
        toggleDisplayRoads = InputSystem.actions.FindAction("Toggle Display Roads");

        set_fuDo_square( 2*PI );

        tilingTexture  =  AssetDatabase.LoadAssetAtPath<Texture2D>( "Assets/Textures/Tilings/" + metricName + "_" + textureNumber.ToString() + ".png" );
        material.SetTexture( "_BaseMap", tilingTexture );

        vulture.state.pos  =  new Vector2( 0.0f, 0.0f );
        vulture.state.vel  =  new Vector2( 0.0f, 0.0f );
        vulture.state.tan  =  new Vector2( 1.0f, 0.0f );
        vulture.state.nor  =  new Vector2( 0.0f, 1.0f );
        vulture.state.ang  =  0;
        vulture.state.sgn  =  1.0f;

        vulture.moveSpeed  =  vultureMoveSpeed;

        observer.state.ang  =  180;

        material.SetVector( "_CamPos", new Vector4( vulture.state.pos.x, vulture.state.pos.y, vulture.state.tan.x, vulture.state.tan.y ) );
        material.SetFloat(  "_CamAng", observer.state.ang );
        material.SetVectorArray( "_RocketsState", rocketsState );
        material.SetFloatArray(  "_RocketsLive",  rocketsLive );

        metricCount     =  22;
        textureCount    =  6;
        roadsTypeCount  =  17;

        accuracy       =  16;
        metricNumber   =  1;
        textureNumber  =  1;
        gsmNumber      =  1;
        roadsType      =  1;

        vultureMoveSpeed   =  2.0f;
        visionRadius       =  2.0f*PI;
        rocketSpeed        =  11.0f;
        rocketInitialLive  =  3.142f;
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
        update_vulture_actions();

        material.SetFloat( "_GameTime", Time.fixedTime );
    }

    private void FixedUpdate()
    {
        update_vulture();
        update_rockets();
        detect_vulture_rocket_collisions();

        material.SetVector( "_CamPos", new Vector4( vulture.state.pos.x, vulture.state.pos.y, vulture.state.tan.x, vulture.state.tan.y ) );
        material.SetFloat(  "_CamAng", observer.state.ang );
        material.SetVectorArray( "_RocketsState", rocketsState );
        material.SetFloatArray(  "_RocketsLive",  rocketsLive );
    }
}