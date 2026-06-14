float confac( float2 p ){
    return 1 / mu(p);
}

float confac_sq( float2 p ){
    return 1 / pow(mu(p),2);
}

float2 christoffel( float2 pv[2] )
{
    float2 cfd  =  -mu_grad( pv[0] ) / mu( pv[0] );

    float a  =  pow( pv[1].x, 2 ) - pow( pv[1].y, 2 );
    float b  =  2 * pv[1].x * pv[1].y;

    return float2( cfd.x*a + cfd.y*b, -cfd.y*a + cfd.x*b );
}