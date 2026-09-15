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

float cop( float2 p, float2 k1, float2 k2 ){ return cop(p,k1) + cop(p,k2); }
float cop( float2 p, float2 k1, float2 k2, float2 k3 ){ return cop(p,k1) + cop(p,k2) + cop(p,k3); }
float cop( float2 p, float2 k1, float2 k2, float2 k3, float2 k4 ){ return cop(p,k1) + cop(p,k2) + cop(p,k3) + cop(p,k4); }
float cop( float2 p, float2 k1, float2 k2, float2 k3, float2 k4, float2 k5 ){ return cop(p,k1) + cop(p,k2) + cop(p,k3) + cop(p,k4) + cop(p,k5); }
float cop( float2 p, float2 k1, float2 k2, float2 k3, float2 k4, float2 k5, float2 k6 ){ return cop(p,k1) + cop(p,k2) + cop(p,k3) + cop(p,k4) + cop(p,k5) + cop(p,k6); }

float sip( float2 p, float2 k1, float2 k2 ){ return sip(p,k1) + sip(p,k2); }
float sip( float2 p, float2 k1, float2 k2, float2 k3 ){ return sip(p,k1) + sip(p,k2) + sip(p,k3); }
float sip( float2 p, float2 k1, float2 k2, float2 k3, float2 k4 ){ return sip(p,k1) + sip(p,k2) + sip(p,k3) + sip(p,k4); }
float sip( float2 p, float2 k1, float2 k2, float2 k3, float2 k4, float2 k5 ){ return sip(p,k1) + sip(p,k2) + sip(p,k3) + sip(p,k4) + sip(p,k5); }
float sip( float2 p, float2 k1, float2 k2, float2 k3, float2 k4, float2 k5, float2 k6 ){ return sip(p,k1) + sip(p,k2) + sip(p,k3) + sip(p,k4) + sip(p,k5) + sip(p,k6); }

float cop_dx( float2 p, float2 k1, float2 k2 ){ return cop_dx(p,k1) + cop_dx(p,k2); }
float cop_dx( float2 p, float2 k1, float2 k2, float2 k3 ){ return cop_dx(p,k1) + cop_dx(p,k2) + cop_dx(p,k3); }
float cop_dx( float2 p, float2 k1, float2 k2, float2 k3, float2 k4 ){ return cop_dx(p,k1) + cop_dx(p,k2) + cop_dx(p,k3) + cop_dx(p,k4); }
float cop_dx( float2 p, float2 k1, float2 k2, float2 k3, float2 k4, float2 k5 ){ return cop_dx(p,k1) + cop_dx(p,k2) + cop_dx(p,k3) + cop_dx(p,k4) + cop_dx(p,k5); }
float cop_dx( float2 p, float2 k1, float2 k2, float2 k3, float2 k4, float2 k5, float2 k6 ){ return cop_dx(p,k1) + cop_dx(p,k2) + cop_dx(p,k3) + cop_dx(p,k4) + cop_dx(p,k5) + cop_dx(p,k6); }

float sip_dx( float2 p, float2 k1, float2 k2 ){ return sip_dx(p,k1) + sip_dx(p,k2); }
float sip_dx( float2 p, float2 k1, float2 k2, float2 k3 ){ return sip_dx(p,k1) + sip_dx(p,k2) + sip_dx(p,k3); }
float sip_dx( float2 p, float2 k1, float2 k2, float2 k3, float2 k4 ){ return sip_dx(p,k1) + sip_dx(p,k2) + sip_dx(p,k3) + sip_dx(p,k4); }
float sip_dx( float2 p, float2 k1, float2 k2, float2 k3, float2 k4, float2 k5 ){ return sip_dx(p,k1) + sip_dx(p,k2) + sip_dx(p,k3) + sip_dx(p,k4) + sip_dx(p,k5); }
float sip_dx( float2 p, float2 k1, float2 k2, float2 k3, float2 k4, float2 k5, float2 k6 ){ return sip_dx(p,k1) + sip_dx(p,k2) + sip_dx(p,k3) + sip_dx(p,k4) + sip_dx(p,k5) + sip_dx(p,k6); }

float cop_dy( float2 p, float2 k1, float2 k2 ){ return cop_dy(p,k1) + cop_dy(p,k2); }
float cop_dy( float2 p, float2 k1, float2 k2, float2 k3 ){ return cop_dy(p,k1) + cop_dy(p,k2) + cop_dy(p,k3); }
float cop_dy( float2 p, float2 k1, float2 k2, float2 k3, float2 k4 ){ return cop_dy(p,k1) + cop_dy(p,k2) + cop_dy(p,k3) + cop_dy(p,k4); }
float cop_dy( float2 p, float2 k1, float2 k2, float2 k3, float2 k4, float2 k5 ){ return cop_dy(p,k1) + cop_dy(p,k2) + cop_dy(p,k3) + cop_dy(p,k4) + cop_dy(p,k5); }
float cop_dy( float2 p, float2 k1, float2 k2, float2 k3, float2 k4, float2 k5, float2 k6 ){ return cop_dy(p,k1) + cop_dy(p,k2) + cop_dy(p,k3) + cop_dy(p,k4) + cop_dy(p,k5) + cop_dy(p,k6); }

float sip_dy( float2 p, float2 k1, float2 k2 ){ return sip_dy(p,k1) + sip_dy(p,k2); }
float sip_dy( float2 p, float2 k1, float2 k2, float2 k3 ){ return sip_dy(p,k1) + sip_dy(p,k2) + sip_dy(p,k3); }
float sip_dy( float2 p, float2 k1, float2 k2, float2 k3, float2 k4 ){ return sip_dy(p,k1) + sip_dy(p,k2) + sip_dy(p,k3) + sip_dy(p,k4); }
float sip_dy( float2 p, float2 k1, float2 k2, float2 k3, float2 k4, float2 k5 ){ return sip_dy(p,k1) + sip_dy(p,k2) + sip_dy(p,k3) + sip_dy(p,k4) + sip_dy(p,k5); }
float sip_dy( float2 p, float2 k1, float2 k2, float2 k3, float2 k4, float2 k5, float2 k6 ){ return sip_dy(p,k1) + sip_dy(p,k2) + sip_dy(p,k3) + sip_dy(p,k4) + sip_dy(p,k5) + sip_dy(p,k6); }