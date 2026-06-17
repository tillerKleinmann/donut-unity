float distance_estimate_from_point( float2 p, float2 q )
{
    return confac( p ) * abs( reset_to_parallelogram( p - q ) );
}

float x_distance_estimate_to_y_parameter_line( float2 p, float q_x )
{
    return confac( float2( q_x, p.y ) ) * abs( reset_to_centered_interval( p.x - q_x, u2p.x ) );
}

float y_distance_estimate_to_x_parameter_line( float2 p, float q_y )
{
    return confac( float2( p.x, q_y ) ) * abs( reset_to_centered_interval( p.y - q_y, u2p.w ) );
}

float2 distance_from_parameter_line( float2 p, float2 q, float2 k )
{
    float2 r = p - q;

    float rk = r.x*k.x + r.y*k.y;
    float lk = length(k);

    return confac( p - k*(rk/pow(lk,2)) ) * abs( reset_to_centered_interval( rk / lk, lk ) );
}