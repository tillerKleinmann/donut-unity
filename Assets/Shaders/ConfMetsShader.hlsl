static const float  Pi  =  3.14159;
static const float   L  =  _VisRad * Pi;
static const int   itn  =  int( _Accuracy );

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

void geodesic_euler_step( float2 pv[2], float dt, out float2 pv_next[2] )
{
    pv_next[0]  =  pv[0] + dt*pv[1];
    pv_next[1]  =  pv[1] - dt*christoffel(pv);
}

half4 frag( Varyings IN ) : SV_Target
{
    float2 xy  =  IN.uv;
    
    xy  =  2*xy - float2(1,1);
    
    float ph0  =  _Time.y;
    
    if( pow(xy.x,2) + pow(xy.y,2) < 1.0 )
    {
        xy  =  xy * L;

        float camRad  =  _CamAng * (2*Pi/360);

        float c = cos( camRad );
        float s = sin( camRad );

        float2 pv[2];
        pv[0]  =  float2( _CamPos.x, _CamPos.y );
        pv[1]  =  mul( xy, float2x2( c, s, -s, c ) ) / confun_exp(pv[0]);
        
        float2 pv_next[2];
        
        float dt  =  1 / float(itn);
        
        for( int i = 0; i < itn; i++ )
        {
            geodesic_euler_step( pv, dt, pv_next );
            pv  =  pv_next;
        }
        
        float2 uv  =  pv_next[0] / ( 2*Pi );
        
        uv.x  +=  0.5;
        uv.y  +=  0.5;
        
        float3 col  =  SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv ).xyz;
        
        return float4( col, 1 );
    }
    else
        return float4( 0, 0, 0, 1 );
}