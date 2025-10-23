static const float  Pi  =  3.14159;
static const float   R  =  _VisRad;
static const int   itn  =  int( _Accuracy );
static const int   gsm  =  int( _GSM );

float confun_exp( float2 p )
{
    return exp( confun( p ) );
}

float confun_exp2( float2 p )
{
    return exp( 2*confun( p ) );
}

float2 christoffel( float2 pv[2] )
{
    float2 cfd  =  confun_d( pv[0] );

    float a  =  pow( pv[1].x, 2 ) - pow( pv[1].y, 2 );
    float b  =  2 * pv[1].x * pv[1].y;

    return float2( cfd.x*a + cfd.y*b, -cfd.y*a + cfd.x*b );
}

float curvature( float2 p )
{
    return -confun_lap( p ) / confun_exp2( p );
}

void geodesic_step__euler( float2 pv[2], float dt, out float2 pv_next[2] )
{
    pv_next[0]  =  pv[0] + dt*pv[1];
    pv_next[1]  =  pv[1] - dt*christoffel(pv);
}

void geodesic_step__midpoint( float2 pv[2], float dt, out float2 pv_next[2] )
{
    float2 pv_mid[2];

    pv_mid[0]  =  pv[0] + (dt/2)*pv[1];
    pv_mid[1]  =  pv[1] - (dt/2)*christoffel(pv);

    pv_next[0]  =  pv[0] + dt*pv_mid[1];
    pv_next[1]  =  pv[1] - dt*christoffel(pv_mid);
}

void geodesic_step__RK4( float2 pv[2], float dt, out float2 pv_next[2] )
{
    float2 k1[2];
    float2 k2[2];
    float2 k3[2];
    float2 k4[2];

    float2 pv2[2];
    float2 pv3[2];
    float2 pv4[2];

    k1[0]  =  pv[1];
    k1[1]  = -christoffel(pv);

    pv2[0]  =  pv[0] + (dt/2)*k1[0];
    pv2[1]  =  pv[1] + (dt/2)*k1[1];

    k2[0]  =  pv2[1];
    k2[1]  = -christoffel(pv2);

    pv3[0]  =  pv[0] + (dt/2)*k2[0];
    pv3[1]  =  pv[1] + (dt/2)*k2[1];

    k3[0]  =  pv3[1];
    k3[1]  = -christoffel(pv3);

    pv4[0]  =  pv[0] + dt*k3[0];
    pv4[1]  =  pv[1] + dt*k3[1];

    k4[0]  =  pv4[1];
    k4[1]  = -christoffel(pv4);

    pv_next[0]  =  pv[0] + (dt/6)*( k1[0] + 2*k2[0] + 2*k3[0] + k4[0] );
    pv_next[1]  =  pv[1] + (dt/6)*( k1[1] + 2*k2[1] + 2*k3[1] + k4[1] );
}

float3 draw_sprite_linear( float3 col, float2 camPos, float2 sprPos, float2 sprVec, Texture2D Tex, float sprScale )
{
    float2 cam2spr = camPos - sprPos;
    
    cam2spr.x  -=  round(cam2spr.x/(2*Pi))*2*Pi;
    cam2spr.y  -=  round(cam2spr.y/(2*Pi))*2*Pi;

    cam2spr *= confun_exp(camPos) / sprScale;

    cam2spr  =  mul( cam2spr, float2x2( -sprVec.x, -sprVec.y, -sprVec.y, sprVec.x ) );

    float2 spr_uv = cam2spr + float2(0.5,0.5);

    float4 sprCol  =  SAMPLE_TEXTURE2D( Tex, sampler_LinearClamp, spr_uv );

    return lerp( col, sprCol.xyz, sprCol.w );
}

half4 frag( Varyings IN ) : SV_Target
{
    float2 xy  =  IN.uv;
    
    xy  =  2*xy - float2(1,1);
    
    float ph0  =  _Time.y;
    
    if( pow(xy.x,2) + pow(xy.y,2) < 1.0 )
    {
        xy  =  xy * R;

        float camRad  =  _CamAng * (2*Pi/360);

        float c = cos( camRad );
        float s = sin( camRad );

        float2 camPos = float2( _CamPos.x, _CamPos.y );
        float2 vulVec = float2( _CamPos.z, _CamPos.w );

        float2 pv[2];
        pv[0]  =  camPos;
        pv[1]  =  mul( xy, float2x2( c, s, -s, c ) ) / confun_exp(camPos);
        
        float2 pv_next[2];
        
        float dt  =  1 / float(itn);

        int i = 0;

        if( gsm == 1 )
            for( ; i < itn; i++ )
            {
                geodesic_step__RK4( pv, dt, pv_next );
                pv  =  pv_next;
            }
        else if( gsm == 2 )
            for( ; i < itn; i++ )
            {
                geodesic_step__midpoint( pv, dt, pv_next );
                pv  =  pv_next;
            }
        else
            for( ; i < itn; i++ )
            {
                geodesic_step__euler( pv, dt, pv_next );
                pv  =  pv_next;
            }

        float2 tarPos  =  pv[0];
        
        float2 uv  =  tarPos / ( 2*Pi );
        
        uv.x  +=  0.5;
        uv.y  +=  0.5;
        
        float3 col  =  SAMPLE_TEXTURE2D( _BaseMap, sampler_LinearRepeat, uv ).xyz;
        
        col  =  draw_sprite_linear( col, tarPos, camPos, vulVec, _VulTex, 1.0 );

        for( int k = 0; k < 16; k++ )
            if( _RocketsLive[k] > 0 )
            {
                float2 rocPos  =  float2( _RocketsState[k].x, _RocketsState[k].y );
                float2 rocVel  =  float2( _RocketsState[k].z, _RocketsState[k].w );
                rocVel  /=  length( rocVel );

                col  =  draw_sprite_linear( col, tarPos, rocPos, rocVel, _RocTex, 0.5 );
            }

        return float4( col, 1 );
    }
    else
        return float4( 0, 0, 0, 1 );
}