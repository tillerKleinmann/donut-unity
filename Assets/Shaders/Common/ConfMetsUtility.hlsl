static const float2 k0 = float2(  0,  2/sqrt(3) );
static const float2 k1 = float2( +1, -1/sqrt(3) );
static const float2 k2 = float2( -1, -1/sqrt(3) );
static const float2 k3 = 2*k0;
static const float2 k4 = 2*k1;
static const float2 k5 = 2*k2;
static const float2 k6 = float2(  2,  0         );
static const float2 k7 = float2( -1, -3/sqrt(3) );
static const float2 k8 = float2( -1, +3/sqrt(3) );

static const float2 k3m = k3/2;
static const float2 k4m = k4/2;
static const float2 k5m = k5/2;
static const float2 k6m = k6/2;
static const float2 k7m = k7/2;
static const float2 k8m = k8/2;

float2 dual_vec( int k, int l )
{
    return float2( k / dp_b, l / dp_h  -  k * (dp_s/(dp_b*dp_h)) );
}

float2 rot120( float2 p )
{
    return float2( -0.5*p.x - sqrt(0.75)*p.y, -0.5*p.y + sqrt(0.75)*p.x );
}

float2 rot240( float2 p )
{
    return float2( -0.5*p.x + sqrt(0.75)*p.y, -0.5*p.y - sqrt(0.75)*p.x );
}

static const float2  k31_0  =  dual_vec( 3, 1 );
static const float2  k31_1  =  rot120( k31_0 );
static const float2  k31_2  =  rot240( k31_0 );

float skap( float2 p, float2 k ){ return p.x*k.x + p.y*k.y; }

float cop( float2 p, float2 k ){ return cos(skap(k,p)); }
float sip( float2 p, float2 k ){ return sin(skap(k,p)); }