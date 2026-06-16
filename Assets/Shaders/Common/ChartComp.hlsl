void geodesic_exp( float2 pv[2], int gsmVar, float visRadVar, out float2 pv_next[2] )
{
    int itn_exp = floor( itn * length(pv[1])/visRadVar ) + 1;
    float dt  =  1 / float(itn_exp);

    geodesic_propagation( pv, dt, gsmVar, itn_exp, pv_next );
}

void fermi_coordinates( float2 pv[2], int gsmVar, float visRadVar, float2 dirVec, out float2 pv_next[2] )
{
    float a  =  dirVec.x*pv[1].x + dirVec.y*pv[1].y;
    float b  = -dirVec.y*pv[1].x + dirVec.x*pv[1].y;

    float ra = abs(a) / visRadVar;
    float rb = abs(b) / visRadVar;

    int itn_exp_a = floor(itn*ra) + 1;
    int itn_exp_b = floor(itn*rb) + 1;

    float dta  =  1 / float(itn_exp_a);
    float dtb  =  1 / float(itn_exp_b);

    float2 aVec  =  dirVec * a;

    pv[1]  =  aVec;
    geodesic_propagation( pv, dta, gsm, itn_exp_a, pv_next );
    pv  =  pv_next;

    pv[1]  =  float2( -pv[1].y, pv[1].x ) * (b/a);
    geodesic_propagation( pv, dtb, gsm, itn_exp_b, pv_next );
    pv  =  pv_next;
}