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
        // la0  =  ( 1.0 - cos( PI * la0 / la ) ) / 2;
        // la1  =  ( 1.0 - cos( PI * la1 / la ) ) / 2;
        // la2  =  ( 1.0 - cos( PI * la2 / la ) ) / 2;
    }

    if( dR_pow2 >= symLineDoubleWidth )
        alpha  =  0.0;
    else if( dR_pow2 < symLineDoubleWidth & dR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  clamp( ( symLineDoubleWidth - dR_pow2 ) / symLineWidth, 0, 1 );
    }
    else if( dR_min < symLineWidth )
    {
        color  =  float3( la0, la1, la2 );
        color  =  lerp( colorGrey, color, clamp( ( symLineWidth - dR_pow2 ) / symLineWidth, 0, 1 ) );
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
        // la0  =  ( 1.0 - cos( PI * la0 / et ) ) / 2;
        // la1  =  ( 1.0 - cos( PI * la1 / et ) ) / 2;
        // la2  =  ( 1.0 - cos( PI * la2 / et ) ) / 2;
        // mu0  =  ( 1.0 - cos( PI * mu0 / et ) ) / 2;
        // mu1  =  ( 1.0 - cos( PI * mu1 / et ) ) / 2;
        // mu2  =  ( 1.0 - cos( PI * mu2 / et ) ) / 2;
    }

    if( dLR_pow2 < symLineDoubleWidth & dLR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  clamp( ( symLineDoubleWidth - dLR_pow2 ) / symLineWidth, 0, 1 );
    }
    else if( dLR_min < symLineWidth )
    {
        color  =  float3( la0, la1, la2 ) + mu0*float3(1.0,0.5,0.5) + mu1*float3(0.5,1.0,0.5) + mu2*float3(0.5,0.5,1.0);
        color  =  lerp( colorGrey, color, clamp( ( symLineWidth - dLR_pow2 ) / symLineWidth, 0, 1 ) );
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
        // la0  =  ( 1.0 - cos( PI * la0 / la ) ) / 2;
        // la1  =  ( 1.0 - cos( PI * la1 / la ) ) / 2;
        // la2  =  ( 1.0 - cos( PI * la2 / la ) ) / 2;
    }

    if( dR_pow2 < symLineDoubleWidth & dR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  clamp( ( symLineDoubleWidth - dR_pow2 ) / symLineWidth, 0, 1 );
    }
    else if( dR_min < symLineWidth )
    {
        color  =  float3( la1 + la2, la0 + la2, la0 + la1 );
        color  =  lerp( colorGrey, color, clamp( ( symLineWidth - dR_pow2 ) / symLineWidth, 0, 1 ) );
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
        // la0  =  ( 1 - cos( PI * la0 / et ) ) / 2;
        // la1  =  ( 1 - cos( PI * la1 / et ) ) / 2;
        // la2  =  ( 1 - cos( PI * la2 / et ) ) / 2;
        // mu0  =  ( 1 - cos( PI * mu0 / et ) ) / 2;
        // mu1  =  ( 1 - cos( PI * mu1 / et ) ) / 2;
        // mu2  =  ( 1 - cos( PI * mu2 / et ) ) / 2;
    }

    if( dLR_pow2 < symLineDoubleWidth & dLR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  clamp( ( symLineDoubleWidth - dLR_pow2 ) / symLineWidth, 0, 1 );
    }
    else if( dLR_min < symLineWidth )
    {
        color  =  float3( la1 + la2, la0 + la2, la0 + la1 ) + mu0*float3(0.0,0.5,0.5) + mu1*float3(0.5,0.0,0.5) + mu2*float3(0.5,0.5,0.0);
        color  =  lerp( colorGrey, color, clamp( ( symLineWidth - dLR_pow2 ) / symLineWidth, 0, 1 ) );
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
        // la0  =  ( 1 - cos( PI * la0 / et ) ) / 2;
        // la1  =  ( 1 - cos( PI * la1 / et ) ) / 2;
        // la2  =  ( 1 - cos( PI * la2 / et ) ) / 2;
        // mu0  =  ( 1 - cos( PI * mu0 / et ) ) / 2;
        // mu1  =  ( 1 - cos( PI * mu1 / et ) ) / 2;
        // mu2  =  ( 1 - cos( PI * mu2 / et ) ) / 2;
    }

    if( dR_pow2 < symLineDoubleWidth & dR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  clamp( ( symLineDoubleWidth - dR_pow2 ) / symLineWidth, 0, 1 );
    }
    else if( dR_min < symLineWidth )
    {
        color  =  float3( la0 + mu1 + mu2, mu0 + la1 + mu2, mu0 + mu1 + la2 );
        color  =  lerp( colorGrey, color, clamp( ( symLineWidth - dR_pow2 ) / symLineWidth, 0, 1 ) );
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
        // la0  =  ( 1 - cos( PI * la0 / et ) ) / 2;
        // la1  =  ( 1 - cos( PI * la1 / et ) ) / 2;
        // la2  =  ( 1 - cos( PI * la2 / et ) ) / 2;
        // mu0  =  ( 1 - cos( PI * mu0 / et ) ) / 2;
        // mu1  =  ( 1 - cos( PI * mu1 / et ) ) / 2;
        // mu2  =  ( 1 - cos( PI * mu2 / et ) ) / 2;
        // la0g  =  ( 1 - cos( PI * la0g / et ) ) / 2;
        // la1g  =  ( 1 - cos( PI * la1g / et ) ) / 2;
        // la2g  =  ( 1 - cos( PI * la2g / et ) ) / 2;
        // mu0g  =  ( 1 - cos( PI * mu0g / et ) ) / 2;
        // mu1g  =  ( 1 - cos( PI * mu1g / et ) ) / 2;
        // mu2g  =  ( 1 - cos( PI * mu2g / et ) ) / 2;
    }

    if( dLR_pow2 < symLineDoubleWidth & dLR_min >= symLineWidth )
    {
        color  =  colorGrey;
        alpha  =  clamp( ( symLineDoubleWidth - dLR_pow2 ) / symLineWidth, 0, 1 );
    }
    else if( dLR_min < symLineWidth )
    {
        color  =    float3( la0 + mu1 + mu2, mu0 + la1 + mu2, mu0 + mu1 + la2 ) 
                    +
                    la0g*float3(1.0,0.5,0.5) + la1g*float3(0.5,1.0,0.5) + la2g*float3(0.5,0.5,1.0)
                    +
                    mu0g*float3(0.0,0.5,0.5) + mu1g*float3(0.5,0.0,0.5) + mu2g*float3(0.5,0.5,0.0);
        
        color  =  lerp( colorGrey, color, clamp( ( symLineWidth - dLR_pow2 ) / symLineWidth, 0, 1 ) );
        alpha  =  1.0;
    }
    else
    {
        alpha  =  0.0;
    }

    return float4( color.x, color.y, color.z, alpha );
}