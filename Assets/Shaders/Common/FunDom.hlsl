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