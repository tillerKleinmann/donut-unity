float confac( float2 p ){
    return lambda(p);
}

float confac_sq( float2 p ){
    return pow( lambda(p), 2 );
}

float2 christoffel( float2 pv[2] )
{
    float2 cfd  =  lambda_grad( pv[0] ) / lambda( pv[0] );

    float a  =  pow( pv[1].x, 2 ) - pow( pv[1].y, 2 );
    float b  =  2 * pv[1].x * pv[1].y;

    return float2( cfd.x*a + cfd.y*b, -cfd.y*a + cfd.x*b );
}