void geodesic_step__euler( float2 pv[2], float dt, out float2 pv_next[2] )
{
    pv_next[0]  =  pv[0] + dt*pv[1];
    pv_next[1]  =  pv[1] - dt*christoffel(pv);
}

void geodesic_step__midpoint( float2 pv[2], float dt, out float2 pv_next[2] )
{
    float2 pv_mid[2];

    pv_mid[0]  =  pv[0] + (dt/2)*pv[1];
    pv_mid[1]  =  pv[1] - (dt/2)*christoffel(pv);

    pv_next[0]  =  pv[0] + dt*pv_mid[1];
    pv_next[1]  =  pv[1] - dt*christoffel(pv_mid);
}

void geodesic_step__RK4( float2 pv[2], float dt, out float2 pv_next[2] )
{
    float2 k1[2];
    float2 k2[2];
    float2 k3[2];
    float2 k4[2];

    float2 pv2[2];
    float2 pv3[2];
    float2 pv4[2];

    k1[0]  =  pv[1];
    k1[1]  = -christoffel(pv);

    pv2[0]  =  pv[0] + (dt/2)*k1[0];
    pv2[1]  =  pv[1] + (dt/2)*k1[1];

    k2[0]  =  pv2[1];
    k2[1]  = -christoffel(pv2);

    pv3[0]  =  pv[0] + (dt/2)*k2[0];
    pv3[1]  =  pv[1] + (dt/2)*k2[1];

    k3[0]  =  pv3[1];
    k3[1]  = -christoffel(pv3);

    pv4[0]  =  pv[0] + dt*k3[0];
    pv4[1]  =  pv[1] + dt*k3[1];

    k4[0]  =  pv4[1];
    k4[1]  = -christoffel(pv4);

    pv_next[0]  =  pv[0] + (dt/6)*( k1[0] + 2*k2[0] + 2*k3[0] + k4[0] );
    pv_next[1]  =  pv[1] + (dt/6)*( k1[1] + 2*k2[1] + 2*k3[1] + k4[1] );
}

void geodesic_propagation( float2 pv[2], float dt, int gsmVar, int itn, out float2 pv_next[2] )
{
    int i = 0;

    if( gsmVar == 1 )
        for( ; i < itn; i++ )
        {
            geodesic_step__RK4( pv, dt, pv_next );
            pv  =  pv_next;
        }
    else if( gsmVar == 2 )
        for( ; i < itn; i++ )
        {
            geodesic_step__midpoint( pv, dt, pv_next );
            pv  =  pv_next;
        }
    else
        for( ; i < itn; i++ )
        {
            geodesic_step__euler( pv, dt, pv_next );
            pv  =  pv_next;
        }
}