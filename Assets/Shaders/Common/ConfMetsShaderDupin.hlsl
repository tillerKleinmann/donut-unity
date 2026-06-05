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
    float2 cfd  =  confun_grad( pv[0] );

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

void geodesic_propagation( float2 pv[2], float dt, int gsmVar, int itn, out float2 pv_next[2] )
{
    int i = 0;

    if( gsmVar == 1 )
        for( ; i < itn; i++ )
        {
            geodesic_step__RK4( pv, dt, pv_next );
            pv  =  pv_next;
        }
    else if( gsmVar == 2 )
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
}

float2 reset_to_unit_square( float2 p )
{
    return float2( p.x - round(p.x), p.y - round(p.y) );
}

float2 reset_to_parallelogram( float2 p )
{
    p  =  mul( p, plg2usq );
    p  =  reset_to_unit_square( p );
    return mul( p, usq2plg );
}

float2 reset_to_unit_square_shifted( float2 p )
{
    return float2( p.x - floor(p.x), p.y - floor(p.y) );
}

float2 reset_to_parallelogram_shifted( float2 p )
{
    p  =  mul( p, plg2usq );
    p  =  reset_to_unit_square_shifted( p );
    return mul( p, usq2plg );
}

float3 draw_sprite_centered( float3 col, float2 pixPos, float2 sprVec, Texture2D Tex, float sprScale )
{
    pixPos *= confun_exp(pixPos) / sprScale;

    pixPos  =  mul( pixPos, float2x2( -sprVec.x, -sprVec.y, -sprVec.y, sprVec.x ) );

    float2 spr_uv = pixPos + float2(0.5,0.5);

    float4 sprCol  =  SAMPLE_TEXTURE2D( Tex, sampler_LinearClamp, spr_uv );

    return lerp( col, sprCol.xyz, sprCol.w );
}

float3 draw_sprite_linear( float3 col, float2 pixPos, float2 sprPos, float2 sprVec, Texture2D Tex, float sprScale )
{
    float2 pix2spr = pixPos - sprPos;
    
    pix2spr = reset_to_parallelogram( pix2spr );

    pix2spr *= confun_exp(sprPos) / sprScale;

    pix2spr  =  mul( pix2spr, float2x2( -sprVec.x, -sprVec.y, -sprVec.y, sprVec.x ) );

    float2 spr_uv = pix2spr + float2(0.5,0.5);

    float4 sprCol  =  SAMPLE_TEXTURE2D( Tex, sampler_LinearClamp, spr_uv );

    return lerp( col, sprCol.xyz, sprCol.w );
}

float3 draw_sprite_quadratic( float3 col, float2 pixPos, float2 sprPos, float2 sprVec, Texture2D Tex, float sprScale )
{
    float2  pix2spr  =  pixPos - sprPos;
    
    pix2spr = reset_to_parallelogram( pix2spr );

    float2  spr_pv[2]  =  { sprPos, pix2spr };
    float2  pix2spr_q  =  pix2spr + 0.5 * christoffel( spr_pv );

    pix2spr_q *= confun_exp(sprPos);

    pix2spr_q  =  mul( pix2spr_q, float2x2( -sprVec.x, -sprVec.y, -sprVec.y, sprVec.x ) ) / sprScale;

    float2 spr_uv  =  pix2spr_q + float2(0.5,0.5);

    float4 sprCol  =  SAMPLE_TEXTURE2D( Tex, sampler_LinearClamp, spr_uv );

    if( length(pix2spr) > 1.0 )
        sprCol.w = 0;

    return lerp( col, sprCol.xyz, sprCol.w );
}

float3 add_main_roads_rectangle( float3 col, float2 tarPos )
{
    float2 tarPos1  =  reset_to_parallelogram( tarPos );
    float2 tarPos2  =  reset_to_parallelogram_shifted( tarPos );

    float dRx  =  confun_exp( float2(0,tarPos1.y) )  * abs(tarPos1.x);
    float drx  =  confun_exp( float2(PI,tarPos2.y) ) * abs(tarPos2.x-PI);
    float dRy  =  confun_exp( float2(tarPos1.x,0) )  * abs(tarPos1.y);
    float dry  =  confun_exp( float2(tarPos2.x,PI) ) * abs(tarPos2.y-PI);

    float roadbr = 0.3;
    float linebr = 0.03;

    if( dRx < roadbr | drx < roadbr | dRy < roadbr | drx < roadbr )
        col  =  float3(0,0,0);
    if( dRx < linebr & dRy > roadbr & dry > roadbr )
        col  =  float3(1,0,0);
    if( drx < linebr & dRy > roadbr & dry > roadbr  )
        col  =  float3(0,1,0);
    if( dRy < linebr & dRx > roadbr & drx > roadbr  )
        col  =  float3(0,0,1);
    if( dry < linebr & dRx > roadbr & drx > roadbr  )
        col  =  float3(1,1,0);

    return col;
}

float3 add_main_roads_rectangle2( float3 col, float2 tarPos )
{
    float2 tarPos1  =  reset_to_parallelogram( tarPos );
    float2 tarPos2  =  reset_to_parallelogram_shifted( tarPos );

    float dRx  =  confun_exp( float2(0,tarPos1.y) )  * abs(tarPos1.x);
    float drx  =  confun_exp( float2(PI,tarPos2.y) ) * abs(tarPos2.x-PI);
    float dRy  =  confun_exp( float2(tarPos1.x,0) )  * abs(tarPos1.y);
    float dry  =  confun_exp( float2(tarPos2.x,PI) ) * abs(tarPos2.y-PI);

    float dmx  =  confun_exp( float2(PI/2,tarPos1.y) )  * abs(tarPos1.x-PI/2);
    float dnx  =  confun_exp( float2(-PI/2,tarPos2.y) ) * abs(tarPos1.x+PI/2);
    float dmy  =  confun_exp( float2(tarPos1.x,PI/2) )  * abs(tarPos1.y-PI/2);
    float dny  =  confun_exp( float2(tarPos2.x,-PI/2) ) * abs(tarPos1.y+PI/2);

    float roadbr = 0.3;
    float linebr = 0.03;

    if( dRx < roadbr | drx < roadbr | dRy < roadbr | drx < roadbr | dmx < roadbr | dnx < roadbr | dmy < roadbr | dny < roadbr )
        col  =  float3(0,0,0);
    if( dRx < linebr & dRy > roadbr & dry > roadbr )
        col  =  float3(1,0,0);
    if( drx < linebr & dRy > roadbr & dry > roadbr  )
        col  =  float3(0,1,0);
    if( dRy < linebr & dRx > roadbr & drx > roadbr  )
        col  =  float3(0,0,1);
    if( dry < linebr & dRx > roadbr & drx > roadbr  )
        col  =  float3(1,1,0);

    return col;
}

float br( float c )
{
    return c*(1+c-c*c);
}

float3 brighter( float3 col )
{
    return float3( br(col.x), br(col.y), br(col.z) );
}

half4 frag( Varyings IN ) : SV_Target
{
    float2 xy  =  IN.uv;
    
    xy  =  2*xy - float2(1,1);
    
    xy.x *= 2;
    
    float ph0  =  _Time.y;
    
    if( ( pow(xy.x,2) + pow(xy.y,2) < 1.0 ) || fullscreen )
    {
        float xy_rl  =  length( xy );

        xy  =  xy * R;

        float c = cos(camRad);
        float s = sin(camRad);

        float2 pv1  =  mul( xy, float2x2( c, s, -s, c ) ) / confun_exp(camPos);

        float2 pv[2];
        pv[0]  =  camPos;
        pv[1]  =  pv1;

        float2 pv_next[2];
        
        if( chartType == 1 )
        {
            int itn_exp = floor( itn*xy_rl ) + 1;
            float dt  =  1 / float(itn_exp);
            geodesic_propagation( pv, dt, gsm, itn_exp, pv_next );
            pv  =  pv_next;
        }
        else if( chartType == 2 )
        {
            float a  =  vulVec.x*pv1.x + vulVec.y*pv1.y;
            float b  = -vulVec.y*pv1.x + vulVec.x*pv1.y;

            float ra = abs(a) / R;
            float rb = abs(b) / R;

            int itn_exp_a = floor(itn*ra) + 1;
            int itn_exp_b = floor(itn*rb) + 1;

            float dta  =  1 / float(itn_exp_a);
            float dtb  =  1 / float(itn_exp_b);

            float2 aVec  =  vulVec * a;

            pv[1]  =  aVec;
            geodesic_propagation( pv, dta, gsm, itn_exp_a, pv_next );
            pv  =  pv_next;

            pv[1]  =  float2( -pv[1].y, pv[1].x ) * (b/a);

            geodesic_propagation( pv, dtb, gsm, itn_exp_b, pv_next );
            pv  =  pv_next;
        }
        else
        {
            pv[0]  +=  pv[1];
        }

        float2 tarPos  =  pv[0];

        float2 uv  =  mul( tarPos, plg2usq );
        
        uv  +=  float2( 0.5, 0.5 );
        
        float3 col  =  SAMPLE_TEXTURE2D( _BaseMap, sampler_LinearRepeat, uv ).xyz;

        col  =  add_main_roads_rectangle2( col, tarPos );

        col  =  draw_sprite_quadratic( col, tarPos, camPos, vulVec, _VulTex, 1.0 );
        
        for( int k = 0; k < 16; k++ )
            if( _RocketsLive[k] > 0 )
            {
                float2 rocPos  =  float2( _RocketsState[k].x, _RocketsState[k].y );
                float2 rocVel  =  float2( _RocketsState[k].z, _RocketsState[k].w );
                rocVel  /=  length( rocVel );

                col  =  draw_sprite_linear( col, tarPos, rocPos, rocVel, _RocTex, 0.5 );
            }

        if( pv1.x*vulVec.x + pv1.y*vulVec.y > length(pv1)*length(vulVec)*255/256 )
            col  =  brighter( col );

        return float4( col, 1 );
    }
    else
        return float4( 0, 0, 0, 0 );
}