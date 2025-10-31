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

    private InputAction moveAction, nextMetric, prevMetric, incrVisRad, decrVisRad, incrAccuracy, decrAccuracy, nextTexture, prevTexture, nextGSM, prevGSM, shoot;

    private Vector2 moveVulture;

    private Vector4[] rocketsState = new Vector4[16];
    private float[] rocketsLive = new float[16];
    private int nextRocket = 0;


    private static float rad2deg = 180/PI;
    private static float deg2rad = PI/180;


    private string metricName = "flat";

    public TextMeshProUGUI domainField, metricField, textureField, radiusField, GSMField, accuracyField, frameRateField;

    private float pollingTime = 1f, time = 0f;
    private int frameCount = 0;

    Material material;


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
            default:
                return 0f;
        }
    }

    private Vector2 confun_grad(Vector2 p, int n)
    {
        switch (n)
        {
            case 1:
                return new Vector2(0, 0);
            case 2:
                return new Vector2(-Sin(p.x) / 4, 0);
            case 3:
                return new Vector2(-Sin(p.x) * Cos(p.y) / 4, -Cos(p.x) * Sin(p.y) / 4);
            case 4:
                return new Vector2(Sin(p.x) * (1 - Cos(p.y)) / 4, Sin(p.y) * (1 - Cos(p.x)) / 4);
            case 5:
                return new Vector2(Sin(p.x) * (Cos(p.y) - 1) / 7, Sin(p.y) * (Cos(p.x) - 1) / 7);
            case 6:
                return new Vector2(-3 * Sin(p.x) * (1 - Pow(Cos(p.x), 2)) / 8, 0);
            case 7:
                return new Vector2(-3 * Sin(p.x) * (1 - Pow(Cos(p.x), 2)) * Cos(p.y) * (3 - Pow(Cos(p.y), 2)) / 8, -3 * Sin(p.y) * (1 - Pow(Cos(p.y), 2)) * Cos(p.x) * (3 - Pow(Cos(p.x), 2)) / 8);
            default:
                return new Vector2(0, 0);
        }
    }
    
    private float distance( Vector2 p, Vector2 q, int n )
    {
        Vector2 diff = reset_to_domain_square(p - q);
        return diff.magnitude * Exp(0.5f * (confun(p, n) + confun(q, n)));
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

        //apply_geodesic_step__euler(ref rp_p, ref rp_v, dt, n);
        apply_geodesic_step__midpoint(ref rp_p, ref rp_v, dt, n);

        rp = new Vector4(rp_p.x, rp_p.y, rp_v.x, rp_v.y);
    }

    private Vector2 move2vel(Vector2 pos, Vector2 moveVec, Vector4 camPos, float camAng, float speed)
    {
        float a = -camAng * deg2rad;

        float c = Cos(a);
        float s = Sin(a);

        return new Vector2(c * moveVec.x + s * moveVec.y, -s * moveVec.x + c * moveVec.y) * (Exp(-confun(pos, metricNumber)) * (-speed));
    }

    private Vector2 reset_to_domain_square(Vector2 p)
    {
        return new Vector2(p.x - RoundToInt(p.x / (2 * PI)) * 2 * PI, p.y - RoundToInt(p.y / (2 * PI)) * 2 * PI);
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

        material.SetFloat("_VisRad", visionRadius);
        material.SetFloat("_Accuracy", accuracy);
        material.SetFloat("_GSM", gsmNumber);

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
        bool metricChanged = false;
        bool textureChanged = false;

        if (nextMetric.WasPressedThisFrame())
        {
            if (metricNumber < 8) metricNumber += 1; else metricNumber = 1;
            metricChanged = true;
        }

        if (prevMetric.WasPressedThisFrame())
        {
            if (metricNumber > 1) metricNumber -= 1; else metricNumber = 8;
            metricChanged = true;
        }

        if (nextTexture.WasPressedThisFrame())
        {
            if (textureNumber < 4) textureNumber += 1; else textureNumber = 1;
            textureChanged = true;
        }

        if (prevTexture.WasPressedThisFrame())
        {
            if (textureNumber > 1) textureNumber -= 1; else textureNumber = 4;
            textureChanged = true;
        }

        if (metricChanged)
        {
            switch (metricNumber)
            {
                case 1:
                    metricName = "flat";
                    domainParameters = make_domain_parameters(2 * PI, 2 * PI, 90);
                    break;
                case 2:
                    metricName = "pseudo";
                    domainParameters = make_domain_parameters(2 * PI, 2 * PI, 90);
                    break;
                case 3:
                    metricName = "camel";
                    domainParameters = make_domain_parameters(2 * PI, 2 * PI, 90);
                    break;
                case 4:
                    metricName = "dromedar";
                    domainParameters = make_domain_parameters(2 * PI, 2 * PI, 90);
                    break;
                case 5:
                    metricName = "rademord";
                    domainParameters = make_domain_parameters(2 * PI, 2 * PI, 90);
                    break;
                case 6:
                    metricName = "pseudoPlateau";
                    domainParameters = make_domain_parameters(2 * PI, 2 * PI, 90);
                    break;
                case 7:
                    metricName = "camelPlateau";
                    domainParameters = make_domain_parameters(2 * PI, 2 * PI, 90);
                    break;
                default:
                    metricName = "hexFlat";
                    domainParameters = make_domain_parameters(2 * PI, 2 * PI, 60);
                    break;
            }

            material.shader = Shader.Find("Custom/Confmets/" + metricName);
            metricField.text = metricName;

            Vector4 domMat = new Vector4(domainParameters.va.x, domainParameters.vb.x, domainParameters.va.y, domainParameters.vb.y);
            material.SetVector("_DomMat", domMat);
        }

        if (textureChanged)
            textureField.text = textureNumber.ToString();

        if (metricChanged | textureChanged)
        {
            tilingTexture = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Textures/Tilings/" + metricName + "_" + textureNumber.ToString() + ".png");
            material.SetTexture("_BaseMap", tilingTexture);
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
        moveVulture = moveAction.ReadValue<Vector2>();

        Vector4 camPos = material.GetVector("_CamPos");
        float camAng = material.GetFloat("_CamAng");

        Vector2 pos = new Vector2(camPos.x, camPos.y);

        Vector2 vel = move2vel(pos, moveVulture, camPos, camAng, vultureMoveSpeed);

        float dt = Time.deltaTime;
        float da = 0;

        //Vector2 new_pos = reset_to_domain_square(pos + dt * vel);
        Vector2 new_pos = reset_to_fundamental_domain(pos + dt * vel, domainParameters);

        camPos.x = new_pos.x;
        camPos.y = new_pos.y;

        if (vel.magnitude > 0)
        {
            Vector2 vulVec = vel.normalized;
            camPos.z = vulVec.x;
            camPos.w = vulVec.y;
        }

        Vector2 accel = -christoffel(pos, vel, vel, metricNumber);
        if (vel.magnitude > 0)
            da = dt * (accel.x * vel.y - accel.y * vel.x) / (vel.x * vel.x + vel.y * vel.y);

        camAng = camAng - da * rad2deg;

        material.SetVector("_CamPos", camPos);
        material.SetFloat("_CamAng", camAng);
    }

    private void update_rockets()
    {
        for (int k = 0; k < 16; k++)
        {
            propagate_rocket(ref rocketsState[k], Time.deltaTime, metricNumber);
            if (rocketsLive[k] > 0)
                rocketsLive[k] -= Time.deltaTime;
        }
    }

    private void detect_vulture_rocket_collisions()
    {
        Vector4 camPos = material.GetVector("_CamPos");

        for (int k = 0; k < 16; k++)
        {
            Vector2 p = new Vector2(rocketsState[k].x, rocketsState[k].y);
            Vector2 q = new Vector2(camPos.x, camPos.y);

            float dist = distance(p, q, metricNumber);

            if (dist < 0.35f)
                if (rocketsLive[k] < 3f)
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

        incrAccuracy = InputSystem.actions.FindAction("Increase Accuracy");
        decrAccuracy = InputSystem.actions.FindAction("Decrease Accuracy");

        incrVisRad = InputSystem.actions.FindAction("Increase Vision Radius");
        decrVisRad = InputSystem.actions.FindAction("Decrease Vision Radius");

        shoot = InputSystem.actions.FindAction("Attack");

        domainParameters = make_domain_parameters(2 * PI, 2 * PI, 90);

        tilingTexture = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/Textures/Tilings/" + metricName + "_" + textureNumber.ToString() + ".png");
        material.SetTexture("_BaseMap", tilingTexture);
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
