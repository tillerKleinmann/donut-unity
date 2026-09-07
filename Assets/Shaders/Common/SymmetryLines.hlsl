static const float symLineWidth        =  0.08;
static const float symLineDoubleWidth  =  2*symLineWidth;

// dual lattice vectors
static const float2 hex_k0  =  float2(  0,       sqrt(3) ) * u2p.x/2;
static const float2 hex_k1  =  float2( +1.5, -sqrt(0.75) ) * u2p.x/2;
static const float2 hex_k2  =  float2( -1.5, -sqrt(0.75) ) * u2p.x/2;

static const float2 hex_k0m  =  float2(  1.0,       0.00  ) * u2p.x/2;
static const float2 hex_k1m  =  float2( -0.5, -sqrt(0.75) ) * u2p.x/2;
static const float2 hex_k2m  =  float2( -0.5, +sqrt(0.75) ) * u2p.x/2;

static const float3 colorGrey  =  float3( 1, 1, 1 ) * 0.5;

float4 symmetry_line_color_alpha__p31m__colored( float2 tarPos )
{
    float3 color;
    float  alpha;

    float dR0  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k0 );
    float dR1  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k1 );
    float dR2  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k2 );

    float dRoad  =  min( dR0, min( dR1, dR2 ) );

    float la0  =  max( 0, symLineWidth - dR0 );
    float la1  =  max( 0, symLineWidth - dR1 );
    float la2  =  max( 0, symLineWidth - dR2 );

    float la  =  la0 + la1 + la2;

    if( la > 0 )
    {
        la0  =  la0 / la;
        la1  =  la1 / la;
        la2  =  la2 / la;
    }

    if( dRoad < symLineDoubleWidth & dRoad >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  clamp( ( symLineDoubleWidth - dRoad ) / symLineWidth, 0, 1 );
    }
    else if( dRoad < symLineWidth )
    {
        color  =  float3( la0, la1, la2 );
        color  =  lerp( colorGrey, color, clamp( ( symLineWidth - dRoad ) / symLineWidth, 0, 1 ) );
        alpha  =  1.0;
    }
    else
    {
        alpha  =  0.0;
    }

    return float4( color.x, color.y, color.z, alpha );
}

float4 symmetry_line_color_alpha__p3m1__colored( float2 tarPos )
{
    float3 color;
    float  alpha;

    float dR0  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k0m );
    float dR1  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k1m );
    float dR2  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k2m );

    float dRoad  =  min( dR0, min( dR1, dR2 ) );

    float la0  =  max( 0, symLineWidth - dR0 );
    float la1  =  max( 0, symLineWidth - dR1 );
    float la2  =  max( 0, symLineWidth - dR2 );

    float la  =  la0 + la1 + la2;

    if( la > 0 )
    {
        la0  =  la0 / la;
        la1  =  la1 / la;
        la2  =  la2 / la;
    }

    if( dRoad < symLineDoubleWidth & dRoad >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  clamp( ( symLineDoubleWidth - dRoad ) / symLineWidth, 0, 1 );
    }
    else if( dRoad < symLineWidth )
    {
        color  =  float3( la1 + la2, la0 + la2, la0 + la1 );
        color  =  lerp( colorGrey, color, clamp( ( symLineWidth - dRoad ) / symLineWidth, 0, 1 ) );
        alpha  =  1.0;
    }
    else
    {
        alpha  =  0.0;
    }

    return float4( color.x, color.y, color.z, alpha );
}

float4 symmetry_line_color_alpha__p6m__colored( float2 tarPos )
{
    float3 color;
    float  alpha;

    float dRp0  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k0 );
    float dRp1  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k1 );
    float dRp2  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k2 );

    float dRs0  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k0m );
    float dRs1  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k1m );
    float dRs2  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k2m );

    float dRp  =  min( dRp0, min( dRp1, dRp2 ) );
    float dRs  =  min( dRs0, min( dRs1, dRs2 ) );
    
    float dR  =  min( dRp, dRs );

    float la0  =  max( 0, symLineWidth - dRp0 );
    float la1  =  max( 0, symLineWidth - dRp1 );
    float la2  =  max( 0, symLineWidth - dRp2 );

    float mu0  =  max( 0, symLineWidth - dRs0 );
    float mu1  =  max( 0, symLineWidth - dRs1 );
    float mu2  =  max( 0, symLineWidth - dRs2 );

    float et  =  la0 + la1 + la2 + mu0 + mu1 + mu2;

    if( et > 0 )
    {
        la0  =  la0 / et;
        la1  =  la1 / et;
        la2  =  la2 / et;
        mu0  =  mu0 / et;
        mu1  =  mu1 / et;
        mu2  =  mu2 / et;
    }

    if( dR < symLineDoubleWidth & dR >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  clamp( ( symLineDoubleWidth - dR ) / symLineWidth, 0, 1 );
    }
    else if( dR < symLineWidth )
    {
        color  =  float3( la0 + mu1 + mu2, mu0 + la1 + mu2, mu0 + mu1 + la2 );
        color  =  lerp( colorGrey, color, clamp( ( symLineWidth - dR ) / symLineWidth, 0, 1 ) );
        alpha  =  1.0;
    }
    else
    {
        alpha  =  0.0;
    }

    return float4( color.x, color.y, color.z, alpha );
}