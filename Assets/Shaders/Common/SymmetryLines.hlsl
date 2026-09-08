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

float4 symmetry_line_color_alpha__pmm__colored( float2 tarPos )
{
    float3 color;
    float  alpha;

    float dRx0  =  x_distance_estimate_to_y_parameter_line( tarPos, 0       );
    float dRx1  =  x_distance_estimate_to_y_parameter_line( tarPos, u2p.x/2 );

    float dRy0  =  y_distance_estimate_to_x_parameter_line( tarPos, 0       );
    float dRy1  =  y_distance_estimate_to_x_parameter_line( tarPos, u2p.w/2 );

    float dR_min  =  min( min( dRx0, dRx1 ), min( dRy0, dRy1 ) );

    float dR_pow2  =  1 / pow( pow(dRx0,-2) + pow(dRx1,-2) + pow(dRy0,-2) + pow(dRy1,-2), 0.5 );

    float la0  =  pow( max( 0, symLineWidth - dRx0 ), 2 );
    float la1  =  pow( max( 0, symLineWidth - dRx1 ), 2 );

    float mu0  =  pow( max( 0, symLineWidth - dRy0 ), 2 );
    float mu1  =  pow( max( 0, symLineWidth - dRy1 ), 2 );

    float et  =  la0 + la1 + mu0 + mu1;

    if( et > 0 )
    {
        la0  =  la0 / et;
        la1  =  la1 / et;
        mu0  =  mu0 / et;
        mu1  =  mu1 / et;
    }

    if( dR_pow2 >= symLineDoubleWidth )
        alpha  =  0.0;
    else if( dR_pow2 < symLineDoubleWidth & dR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  pow( sin( PI/2 * clamp( 2 - dR_pow2/symLineWidth, 0, 1 ) ), 2 );
    }
    else if( dR_min < symLineWidth )
    {
        color  =  ( la0*float3(5,0,7) + la1*float3(3,8,1) + mu0*float3(0,5,7) + mu1*float3(8,3,1) ) / 8;

        color  =  lerp( colorGrey, color, pow( cos( PI/2 * dR_min/symLineWidth ), 2 ) );
        alpha  =  1.0;
    }

    return float4( color.x, color.y, color.z, alpha );
}

float4 symmetry_line_color_alpha__pmg__colored( float2 tarPos )
{
    float3 color;
    float  alpha;

    float dRx0  =    x_distance_estimate_to_y_parameter_line( tarPos,   u2p.x/4 );
    float dRx1  =    x_distance_estimate_to_y_parameter_line( tarPos, 3*u2p.x/4 );

    float dRy0  =  2*y_distance_estimate_to_x_parameter_line( tarPos, 0       );
    float dRy1  =  2*y_distance_estimate_to_x_parameter_line( tarPos, u2p.w/2 );

    float dR_min  =  min( min( dRx0, dRx1 ), min( dRy0, dRy1 ) );

    float dR_pow2  =  1 / pow( pow(dRx0,-2) + pow(dRx1,-2) + pow(dRy0,-2) + pow(dRy1,-2), 0.5 );

    float la0  =  pow( max( 0, symLineWidth - dRx0 ), 2 );
    float la1  =  pow( max( 0, symLineWidth - dRx1 ), 2 );

    float mu0  =  pow( max( 0, symLineWidth - dRy0 ), 2 );
    float mu1  =  pow( max( 0, symLineWidth - dRy1 ), 2 );

    float et  =  la0 + la1 + mu0 + mu1;

    if( et > 0 )
    {
        la0  =  la0 / et;
        la1  =  la1 / et;
        mu0  =  mu0 / et;
        mu1  =  mu1 / et;
    }

    if( dR_pow2 >= symLineDoubleWidth )
        alpha  =  0.0;
    else if( dR_pow2 < symLineDoubleWidth & dR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  pow( sin( PI/2 * clamp( 2 - dR_pow2/symLineWidth, 0, 1 ) ), 2 );
    }
    else if( dR_min < symLineWidth )
    {
        color  =  ( la0*float3(5,0,7) + la1*float3(3,8,1) + mu0*float3(0,5,7) + mu1*float3(8,3,1) ) / 8;

        color  =  lerp( colorGrey, color, pow( cos( PI/2 * dR_min/symLineWidth ), 2 ) );
        alpha  =  1.0;
    }

    return float4( color.x, color.y, color.z, alpha );
}

float4 symmetry_line_color_alpha__pgg__colored( float2 tarPos )
{
    float3 color;
    float  alpha;

    float dRx0  =  2*x_distance_estimate_to_y_parameter_line( tarPos,   u2p.x/4 );
    float dRx1  =  2*x_distance_estimate_to_y_parameter_line( tarPos, 3*u2p.x/4 );

    float dRy0  =  2*y_distance_estimate_to_x_parameter_line( tarPos,   u2p.w/4 );
    float dRy1  =  2*y_distance_estimate_to_x_parameter_line( tarPos, 3*u2p.w/4 );

    float dR_min  =  min( min( dRx0, dRx1 ), min( dRy0, dRy1 ) );

    float dR_pow2  =  1 / pow( pow(dRx0,-2) + pow(dRx1,-2) + pow(dRy0,-2) + pow(dRy1,-2), 0.5 );

    float la0  =  pow( max( 0, symLineWidth - dRx0 ), 2 );
    float la1  =  pow( max( 0, symLineWidth - dRx1 ), 2 );

    float mu0  =  pow( max( 0, symLineWidth - dRy0 ), 2 );
    float mu1  =  pow( max( 0, symLineWidth - dRy1 ), 2 );

    float et  =  la0 + la1 + mu0 + mu1;

    if( et > 0 )
    {
        la0  =  la0 / et;
        la1  =  la1 / et;
        mu0  =  mu0 / et;
        mu1  =  mu1 / et;
    }

    if( dR_pow2 >= symLineDoubleWidth )
        alpha  =  0.0;
    else if( dR_pow2 < symLineDoubleWidth & dR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  pow( sin( PI/2 * clamp( 2 - dR_pow2/symLineWidth, 0, 1 ) ), 2 );
    }
    else if( dR_min < symLineWidth )
    {
        color  =  ( la0*float3(5,0,7) + la1*float3(3,8,1) + mu0*float3(0,5,7) + mu1*float3(8,3,1) ) / 8;

        color  =  lerp( colorGrey, color, pow( cos( PI/2 * dR_min/symLineWidth ), 2 ) );
        alpha  =  1.0;
    }

    return float4( color.x, color.y, color.z, alpha );
}

float4 symmetry_line_color_alpha__p4m__colored( float2 tarPos )
{
    float3 color;
    float  alpha;

    float dRx0  =  x_distance_estimate_to_y_parameter_line( tarPos, 0       );
    float dRx1  =  x_distance_estimate_to_y_parameter_line( tarPos, u2p.x/2 );

    float dRy0  =  y_distance_estimate_to_x_parameter_line( tarPos, 0       );
    float dRy1  =  y_distance_estimate_to_x_parameter_line( tarPos, u2p.w/2 );

    float dDp0  =    distance_from_parameter_line( tarPos, float2(  0, 0 ), PI*float2(1,1) );
    float dDp1  =  2*distance_from_parameter_line( tarPos, float2( PI, 0 ), PI*float2(1,1) );

    float dDm0  =    distance_from_parameter_line( tarPos, float2(  0, 0 ), PI*float2(-1,1) );
    float dDm1  =  2*distance_from_parameter_line( tarPos, float2( PI, 0 ), PI*float2(-1,1) );

    float dR_min  =  min( min( min( dRx0, dRx1 ), min( dRy0, dRy1 ) ), min( min( dDp0, dDp1 ), min( dDm0, dDm1 ) ) );

    float dR_pow2  =  1 / pow( pow(dRx0,-2) + pow(dRx1,-2) + pow(dRy0,-2) + pow(dRy1,-2) + pow(dDp0,-2) + pow(dDp1,-2) + pow(dDm0,-2) + pow(dDm1,-2), 0.5 );

    float lax0  =  pow( max( 0, symLineWidth - dRx0 ), 2 );
    float lax1  =  pow( max( 0, symLineWidth - dRx1 ), 2 );

    float lay0  =  pow( max( 0, symLineWidth - dRy0 ), 2 );
    float lay1  =  pow( max( 0, symLineWidth - dRy1 ), 2 );

    float mup0  =  pow( max( 0, symLineWidth - dDp0 ), 2 );
    float mup1  =  pow( max( 0, symLineWidth - dDp1 ), 2 );

    float mus0  =  pow( max( 0, symLineWidth - dDm0 ), 2 );
    float mus1  =  pow( max( 0, symLineWidth - dDm1 ), 2 );

    float et  =  lax0 + lax1 + lay0 + lay1 + mup0 + mup1 + mus0 + mus1;

    if( et > 0 )
    {
        lax0  =  lax0 / et;
        lax1  =  lax1 / et;
        lay0  =  lay0 / et;
        lay1  =  lay1 / et;
        mup0  =  mup0 / et;
        mup1  =  mup1 / et;
        mus0  =  mus0 / et;
        mus1  =  mus1 / et;
    }

    if( dR_pow2 >= symLineDoubleWidth )
        alpha  =  0.0;
    else if( dR_pow2 < symLineDoubleWidth & dR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  pow( sin( PI/2 * clamp( 2 - dR_pow2/symLineWidth, 0, 1 ) ), 2 );
    }
    else if( dR_min < symLineWidth )
    {
        color  =  float3( lax0 + lay1 + mup1 + mus0, lay0 + lax1 + mup1 + mus0, mup0 + lax1 + lay1 + mus0 );

        color  =  lerp( colorGrey, color, pow( cos( PI/2 * dR_min/symLineWidth ), 2 ) );
        alpha  =  1.0;
    }

    return float4( color.x, color.y, color.z, alpha );
}

float4 symmetry_line_color_alpha__p4g__colored( float2 tarPos )
{
    float3 color;
    float  alpha;

    float dRx0  =  2*x_distance_estimate_to_y_parameter_line( tarPos, 0       );
    float dRx1  =  2*x_distance_estimate_to_y_parameter_line( tarPos, u2p.x/2 );

    float dRy0  =  2*y_distance_estimate_to_x_parameter_line( tarPos, 0       );
    float dRy1  =  2*y_distance_estimate_to_x_parameter_line( tarPos, u2p.w/2 );

    float dDp0  =  2*distance_from_parameter_line( tarPos, float2(  0, 0 ), PI*float2(1,1) );
    float dDp1  =    distance_from_parameter_line( tarPos, float2( PI, 0 ), PI*float2(1,1) );

    float dDm0  =  2*distance_from_parameter_line( tarPos, float2(  0, 0 ), PI*float2(-1,1) );
    float dDm1  =    distance_from_parameter_line( tarPos, float2( PI, 0 ), PI*float2(-1,1) );

    float dR_min  =  min( min( min( dRx0, dRx1 ), min( dRy0, dRy1 ) ), min( min( dDp0, dDp1 ), min( dDm0, dDm1 ) ) );

    float dR_pow2  =  1 / pow( pow(dRx0,-2) + pow(dRx1,-2) + pow(dRy0,-2) + pow(dRy1,-2) + pow(dDp0,-2) + pow(dDp1,-2) + pow(dDm0,-2) + pow(dDm1,-2), 0.5 );

    float lax0  =  pow( max( 0, symLineWidth - dRx0 ), 2 );
    float lax1  =  pow( max( 0, symLineWidth - dRx1 ), 2 );

    float lay0  =  pow( max( 0, symLineWidth - dRy0 ), 2 );
    float lay1  =  pow( max( 0, symLineWidth - dRy1 ), 2 );

    float mup0  =  pow( max( 0, symLineWidth - dDp0 ), 2 );
    float mup1  =  pow( max( 0, symLineWidth - dDp1 ), 2 );

    float mus0  =  pow( max( 0, symLineWidth - dDm0 ), 2 );
    float mus1  =  pow( max( 0, symLineWidth - dDm1 ), 2 );

    float et  =  lax0 + lax1 + lay0 + lay1 + mup0 + mup1 + mus0 + mus1;

    if( et > 0 )
    {
        lax0  =  lax0 / et;
        lax1  =  lax1 / et;
        lay0  =  lay0 / et;
        lay1  =  lay1 / et;
        mup0  =  mup0 / et;
        mup1  =  mup1 / et;
        mus0  =  mus0 / et;
        mus1  =  mus1 / et;
    }

    if( dR_pow2 >= symLineDoubleWidth )
        alpha  =  0.0;
    else if( dR_pow2 < symLineDoubleWidth & dR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  pow( sin( PI/2 * clamp( 2 - dR_pow2/symLineWidth, 0, 1 ) ), 2 );
    }
    else if( dR_min < symLineWidth )
    {
        color  =  float3( lax0 + lay1 + mup1 + mus0, lay0 + lax1 + mup1 + mus0, mup0 + lax1 + lay1 + mus0 );

        color  =  lerp( colorGrey, color, pow( cos( PI/2 * dR_min/symLineWidth ), 2 ) );
        alpha  =  1.0;
    }

    return float4( color.x, color.y, color.z, alpha );
}

float4 symmetry_line_color_alpha__p31m__colored( float2 tarPos )
{
    float3 color;
    float  alpha;

    float dR0  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k0 );
    float dR1  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k1 );
    float dR2  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k2 );

    float dR_min  =  min( dR0, min( dR1, dR2 ) );

    float dR_pow2  =  1 / pow( pow(dR0,-2) + pow(dR1,-2) + pow(dR2,-2), 0.5 );

    float la0  =  pow( max( 0, symLineWidth - dR0 ), 2 );
    float la1  =  pow( max( 0, symLineWidth - dR1 ), 2 );
    float la2  =  pow( max( 0, symLineWidth - dR2 ), 2 );

    float la  =  la0 + la1 + la2;

    if( la > 0 )
    {
        la0  =  la0 / la;
        la1  =  la1 / la;
        la2  =  la2 / la;
    }

    if( dR_pow2 >= symLineDoubleWidth )
        alpha  =  0.0;
    else if( dR_pow2 < symLineDoubleWidth & dR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  pow( sin( PI/2 * clamp( 2 - dR_pow2/symLineWidth, 0, 1 ) ), 2 );
    }
    else if( dR_min < symLineWidth )
    {
        color  =  float3( la0, la1, la2 );

        color  =  lerp( colorGrey, color, pow( cos( PI/2 * dR_min/symLineWidth ), 2 ) );
        alpha  =  1.0;
    }

    return float4( color.x, color.y, color.z, alpha );
}

float4 symmetry_line_color_alpha__p31m_glide__colored( float2 tarPos )
{
    float3 color;
    float  alpha;

    float dR0  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k0 );
    float dR1  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k1 );
    float dR2  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k2 );

    float dL0  =  2*distance_from_parameter_line( tarPos, hex_k1, hex_k0 );
    float dL1  =  2*distance_from_parameter_line( tarPos, hex_k2, hex_k1 );
    float dL2  =  2*distance_from_parameter_line( tarPos, hex_k0, hex_k2 );

    float dR_min  =  min( dR0, min( dR1, dR2 ) );
    float dL_min  =  min( dL0, min( dL1, dL2 ) );

    float dLR_min  =  min( dL_min, dR_min );

    float dLR_pow2  =  1 / pow( pow(dR0,-2) + pow(dR1,-2) + pow(dR2,-2) + pow(dL0,-2) + pow(dL1,-2) + pow(dL2,-2), 0.5 );

    float la0  =  pow( max( 0, symLineWidth - dR0 ), 2 );
    float la1  =  pow( max( 0, symLineWidth - dR1 ), 2 );
    float la2  =  pow( max( 0, symLineWidth - dR2 ), 2 );

    float mu0  =  pow( max( 0, symLineWidth - dL0 ), 2 );
    float mu1  =  pow( max( 0, symLineWidth - dL1 ), 2 );
    float mu2  =  pow( max( 0, symLineWidth - dL2 ), 2 );

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

    if( dLR_pow2 < symLineDoubleWidth & dLR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  pow( sin( PI/2 * clamp( 2 - dLR_pow2/symLineWidth, 0, 1 ) ), 2 );
    }
    else if( dLR_min < symLineWidth )
    {
        color   =   float3( la0, la1, la2 )
                    +
                    mu0*float3(1.0,0.5,0.5) + mu1*float3(0.5,1.0,0.5) + mu2*float3(0.5,0.5,1.0);

        color  =  lerp( colorGrey, color, pow( cos( PI/2 * dLR_min/symLineWidth ), 2 ) );
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

    float dR_min  =  min( dR0, min( dR1, dR2 ) );

    float dR_pow2  =  1 / pow( pow(dR0,-2) + pow(dR1,-2) + pow(dR2,-2), 0.5 );

    float la0  =  pow( max( 0, symLineWidth - dR0 ), 2 );
    float la1  =  pow( max( 0, symLineWidth - dR1 ), 2 );
    float la2  =  pow( max( 0, symLineWidth - dR2 ), 2 );

    float la  =  la0 + la1 + la2;

    if( la > 0 )
    {
        la0  =  la0 / la;
        la1  =  la1 / la;
        la2  =  la2 / la;
    }

    if( dR_pow2 < symLineDoubleWidth & dR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  pow( sin( PI/2 * clamp( 2 - dR_pow2/symLineWidth, 0, 1 ) ), 2 );
    }
    else if( dR_min < symLineWidth )
    {
        color  =  float3( la1 + la2, la0 + la2, la0 + la1 );

        color  =  lerp( colorGrey, color, pow( cos( PI/2 * dR_min/symLineWidth ), 2 ) );
        alpha  =  1.0;
    }
    else
    {
        alpha  =  0.0;
    }

    return float4( color.x, color.y, color.z, alpha );
}

float4 symmetry_line_color_alpha__p3m1_glide__colored( float2 tarPos )
{
    float3 color;
    float  alpha;

    float dR0  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k0m );
    float dR1  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k1m );
    float dR2  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k2m );

    float dL0  =  2*distance_from_parameter_line( tarPos, hex_k1m, hex_k0m );
    float dL1  =  2*distance_from_parameter_line( tarPos, hex_k2m, hex_k1m );
    float dL2  =  2*distance_from_parameter_line( tarPos, hex_k0m, hex_k2m );

    float dR  =  min( dR0, min( dR1, dR2 ) );
    float dL  =  min( dL0, min( dL1, dL2 ) );

    float dLR_min  =  min( dL, dR );

    float dLR_pow2  =  1 / pow( pow(dR0,-2) + pow(dR1,-2) + pow(dR2,-2) + pow(dL0,-2) + pow(dL1,-2) + pow(dL2,-2), 0.5 );

    float la0  =  pow( max( 0, symLineWidth - dR0 ), 2 );
    float la1  =  pow( max( 0, symLineWidth - dR1 ), 2 );
    float la2  =  pow( max( 0, symLineWidth - dR2 ), 2 );

    float mu0  =  pow( max( 0, symLineWidth - dL0 ), 2 );
    float mu1  =  pow( max( 0, symLineWidth - dL1 ), 2 );
    float mu2  =  pow( max( 0, symLineWidth - dL2 ), 2 );

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

    if( dLR_pow2 < symLineDoubleWidth & dLR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  pow( sin( PI/2 * clamp( 2 - dLR_pow2/symLineWidth, 0, 1 ) ), 2 );
    }
    else if( dLR_min < symLineWidth )
    {
        color   =   float3( la1 + la2, la0 + la2, la0 + la1 )
                    +
                    mu0*float3(0.0,0.5,0.5) + mu1*float3(0.5,0.0,0.5) + mu2*float3(0.5,0.5,0.0);

        color  =  lerp( colorGrey, color, pow( cos( PI/2 * dLR_min/symLineWidth ), 2 ) );
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
    
    float dR_min  =  min( dRp, dRs );

    float dR_pow2  =  1 / pow( pow(dRp0,-2) + pow(dRp1,-2) + pow(dRp2,-2) + pow(dRs0,-2) + pow(dRs1,-2) + pow(dRs2,-2), 0.5 );

    float la0  =  pow( max( 0, symLineWidth - dRp0 ), 2 );
    float la1  =  pow( max( 0, symLineWidth - dRp1 ), 2 );
    float la2  =  pow( max( 0, symLineWidth - dRp2 ), 2 );

    float mu0  =  pow( max( 0, symLineWidth - dRs0 ), 2 );
    float mu1  =  pow( max( 0, symLineWidth - dRs1 ), 2 );
    float mu2  =  pow( max( 0, symLineWidth - dRs2 ), 2 );

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

    if( dR_pow2 < symLineDoubleWidth & dR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  pow( sin( PI/2 * clamp( 2 - dR_pow2/symLineWidth, 0, 1 ) ), 2 );
    }
    else if( dR_min < symLineWidth )
    {
        color  =  float3( la0 + mu1 + mu2, mu0 + la1 + mu2, mu0 + mu1 + la2 );
        
        color  =  lerp( colorGrey, color, pow( cos( PI/2 * dR_min/symLineWidth ), 2 ) );
        alpha  =  1.0;
    }
    else
    {
        alpha  =  0.0;
    }

    return float4( color.x, color.y, color.z, alpha );
}

float4 symmetry_line_color_alpha__p6m_glide__colored( float2 tarPos )
{
    float3 color;
    float  alpha;

    float dRp0  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k0 );
    float dRp1  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k1 );
    float dRp2  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k2 );

    float dRs0  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k0m );
    float dRs1  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k1m );
    float dRs2  =  distance_from_parameter_line( tarPos, float2(0,0), hex_k2m );

    float dLp0  =  2*distance_from_parameter_line( tarPos, hex_k1, hex_k0 );
    float dLp1  =  2*distance_from_parameter_line( tarPos, hex_k2, hex_k1 );
    float dLp2  =  2*distance_from_parameter_line( tarPos, hex_k0, hex_k2 );

    float dLs0  =  2*distance_from_parameter_line( tarPos, hex_k1m, hex_k0m );
    float dLs1  =  2*distance_from_parameter_line( tarPos, hex_k2m, hex_k1m );
    float dLs2  =  2*distance_from_parameter_line( tarPos, hex_k0m, hex_k2m );

    float dRp  =  min( dRp0, min( dRp1, dRp2 ) );
    float dRs  =  min( dRs0, min( dRs1, dRs2 ) );

    float dR  =  min( dRp, dRs );

    float dLp  =  min( dLp0, min( dLp1, dLp2 ) );
    float dLs  =  min( dLs0, min( dLs1, dLs2 ) );

    float dL  =  min( dLp, dLs );

    float dLR_min  =  min( dR, dL );

    float dLR_pow2  =  1 / pow( pow(dRp0,-2) + pow(dRp1,-2) + pow(dRp2,-2) + pow(dRs0,-2) + pow(dRs1,-2) + pow(dRs2,-2) + pow(dLp0,-2) + pow(dLp1,-2) + pow(dLp2,-2) + pow(dLs0,-2) + pow(dLs1,-2) + pow(dLs2,-2), 0.5 );
    
    float la0  =  pow( max( 0, symLineWidth - dRp0 ), 2 );
    float la1  =  pow( max( 0, symLineWidth - dRp1 ), 2 );
    float la2  =  pow( max( 0, symLineWidth - dRp2 ), 2 );

    float mu0  =  pow( max( 0, symLineWidth - dRs0 ), 2 );
    float mu1  =  pow( max( 0, symLineWidth - dRs1 ), 2 );
    float mu2  =  pow( max( 0, symLineWidth - dRs2 ), 2 );

    float la0g  =  pow( max( 0, symLineWidth - dLp0 ), 2 );
    float la1g  =  pow( max( 0, symLineWidth - dLp1 ), 2 );
    float la2g  =  pow( max( 0, symLineWidth - dLp2 ), 2 );

    float mu0g  =  pow( max( 0, symLineWidth - dLs0 ), 2 );
    float mu1g  =  pow( max( 0, symLineWidth - dLs1 ), 2 );
    float mu2g  =  pow( max( 0, symLineWidth - dLs2 ), 2 );

    float et  =  la0 + la1 + la2 + mu0 + mu1 + mu2 + la0g + la1g + la2g + mu0g + mu1g + mu2g;

    if( et > 0 )
    {
        la0  =  la0 / et;
        la1  =  la1 / et;
        la2  =  la2 / et;
        mu0  =  mu0 / et;
        mu1  =  mu1 / et;
        mu2  =  mu2 / et;
        la0g  =  la0g / et;
        la1g  =  la1g / et;
        la2g  =  la2g / et;
        mu0g  =  mu0g / et;
        mu1g  =  mu1g / et;
        mu2g  =  mu2g / et;
    }

    if( dLR_pow2 < symLineDoubleWidth & dLR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  pow( sin( PI/2 * clamp( 2 - dLR_pow2/symLineWidth, 0, 1 ) ), 2 );
    }
    else if( dLR_min < symLineWidth )
    {
        color   =   float3( la0 + mu1 + mu2, mu0 + la1 + mu2, mu0 + mu1 + la2 ) 
                    +
                    la0g*float3(1.0,0.5,0.5) + la1g*float3(0.5,1.0,0.5) + la2g*float3(0.5,0.5,1.0)
                    +
                    mu0g*float3(0.0,0.5,0.5) + mu1g*float3(0.5,0.0,0.5) + mu2g*float3(0.5,0.5,0.0);

        color  =  lerp( colorGrey, color, pow( cos( PI/2 * dLR_min/symLineWidth ), 2 ) );
        alpha  =  1.0;
    }
    else
    {
        alpha  =  0.0;
    }

    return float4( color.x, color.y, color.z, alpha );
}