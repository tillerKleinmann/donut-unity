float confac( float2 p ){
    return exp( psi(p) );
}

float confac_sq( float2 p ){
    return exp( 2*psi(p) );
}

float2 christoffel( float2 pv[2] )
{
    float2 cfd  =  psi_grad( pv[0] );

    float a  =  pow( pv[1].x, 2 ) - pow( pv[1].y, 2 );
    float b  =  2 * pv[1].x * pv[1].y;

    return float2( cfd.x*a + cfd.y*b, -cfd.y*a + cfd.x*b );
}