float reset_to_centered_unit_interval( float x )
{
    return x - round(x);
}

float reset_to_centered_interval( float x, float a )
{
    return a*reset_to_centered_unit_interval( x/a );
}

float reset_to_unit_interval( float x )
{
    return x - floor(x);
}

float reset_to_interval( float x, float a )
{
    return a*reset_to_unit_interval(x/a);
}

float reset_to_general_interval( float x, float a, float b )
{
    return a + reset_to_interval( x - a, b - a );
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