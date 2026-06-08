half4 frag( Varyings IN ) : SV_Target
{
    float2 xy  =  IN.uv;
    
    xy  =  2*xy - float2(1,1);
    
    xy.x *= 2;
    
    float ph0  =  _Time.y;
    
    if( ( pow(xy.x,2) + pow(xy.y,2) < 1.0 ) || fullscreen )
    {
        float xy_rl  =  length( xy );

        xy  =  xy * R;

        float c = cos(camRad);
        float s = sin(camRad);

        float2 pv1  =  mul( xy, float2x2( c, s, -s, c ) ) / confac(camPos);

        float2 pv[2];
        pv[0]  =  camPos;
        pv[1]  =  pv1;

        float2 pv_next[2];
        
        if( chartType == 1 )
        {
            int itn_exp = floor( itn*xy_rl ) + 1;
            float dt  =  1 / float(itn_exp);
            geodesic_propagation( pv, dt, gsm, itn_exp, pv_next );
            pv  =  pv_next;
        }
        else if( chartType == 2 )
        {
            float a  =  vulVec.x*pv1.x + vulVec.y*pv1.y;
            float b  = -vulVec.y*pv1.x + vulVec.x*pv1.y;

            float ra = abs(a) / R;
            float rb = abs(b) / R;

            int itn_exp_a = floor(itn*ra) + 1;
            int itn_exp_b = floor(itn*rb) + 1;

            float dta  =  1 / float(itn_exp_a);
            float dtb  =  1 / float(itn_exp_b);

            float2 aVec  =  vulVec * a;

            pv[1]  =  aVec;
            geodesic_propagation( pv, dta, gsm, itn_exp_a, pv_next );
            pv  =  pv_next;

            pv[1]  =  float2( -pv[1].y, pv[1].x ) * (b/a);

            geodesic_propagation( pv, dtb, gsm, itn_exp_b, pv_next );
            pv  =  pv_next;
        }
        else
        {
            pv[0]  +=  pv[1];
        }

        float2 tarPos  =  pv[0];

        float2 uv  =  mul( tarPos, plg2usq );
        
        uv  +=  float2( 0.5, 0.5 );
        
        float3 col  =  SAMPLE_TEXTURE2D( _BaseMap, sampler_LinearRepeat, uv ).xyz;

        col  =  add_main_roads_rectangle2( col, tarPos );

        col  =  draw_sprite_quadratic( col, tarPos, camPos, vulVec, _VulTex, 1.0 );
        
        for( int k = 0; k < 16; k++ )
            if( _RocketsLive[k] > 0 )
            {
                float2 rocPos  =  float2( _RocketsState[k].x, _RocketsState[k].y );
                float2 rocVel  =  float2( _RocketsState[k].z, _RocketsState[k].w );
                rocVel  /=  length( rocVel );

                col  =  draw_sprite_linear( col, tarPos, rocPos, rocVel, _RocTex, 0.5 );
            }

        if( pv1.x*vulVec.x + pv1.y*vulVec.y > length(pv1)*length(vulVec)*255/256 )
            col  =  brighter( col );

        return float4( col, 1 );
    }
    else
        return float4( 0, 0, 0, 0 );
}