float2 dual_lattice_vector( int k, int l )
{
    return float2( k / dp_b, l / dp_h  +  k * (dp_s/(dp_b*dp_h)) ) * 2*PI;
}

float2 rot180( float2 p ){ return float2( -p.x,  p.y ); }

float2 rot90(  float2 p ){ return float2( -p.y,  p.x ); }
float2 rot270( float2 p ){ return float2(  p.y, -p.x ); }

float2 rot120( float2 p ){ return float2( -0.5*p.x - sqrt(0.75)*p.y, -0.5*p.y + sqrt(0.75)*p.x ); }
float2 rot240( float2 p ){ return float2( -0.5*p.x + sqrt(0.75)*p.y, -0.5*p.y - sqrt(0.75)*p.x ); }

float2 rot60(  float2 p ){ return float2(  0.5*p.x - sqrt(0.75)*p.y,  0.5*p.y + sqrt(0.75)*p.x ); }
float2 rot300( float2 p ){ return float2(  0.5*p.x + sqrt(0.75)*p.y,  0.5*p.y - sqrt(0.75)*p.x ); }

float skap( float2 p, float2 k ){ return p.x*k.x + p.y*k.y; }

float cop( float2 p, float2 k ){ return cos( skap( k, p ) ); }
float sip( float2 p, float2 k ){ return sin( skap( k, p ) ); }

float cop_dx( float2 p, float2 k ){ return -sip(k,p)*k.x; }
float sip_dx( float2 p, float2 k ){ return  cop(k,p)*k.x; }

float cop_dy( float2 p, float2 k ){ return -sip(k,p)*k.y; }
float sip_dy( float2 p, float2 k ){ return  cop(k,p)*k.y; }