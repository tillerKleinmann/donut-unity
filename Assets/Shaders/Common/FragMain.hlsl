half4 frag( Varyings IN ) : SV_Target
{
    float2 xy  =  IN.uv;
    
    xy  =  2*xy - float2(1,1);
    
    xy.x *= 2;
    
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
        
        if( chartType == 1 )
        {
            float2 pv_next[2];
            geodesic_exp( pv, gsm, R, pv_next );
            pv  =  pv_next;
        }
        else if( chartType == 2 )
        {
            float2 pv_next[2];
            fermi_coordinates( pv, gsm, R, vulVec, pv_next );
            pv  =  pv_next;
        }
        else
        {
            pv[0]  +=  pv[1];
        }

        float2 tarPos  =  pv[0];

        float2 uv  =  mul( tarPos, plg2usq );
        
        uv  +=  float2(1,1)*0.5;

        uv  =  reset_to_unit_square_shifted( uv );

        float3 col  =  SAMPLE_TEXTURE2D( _BaseMap, sampler_LinearRepeat, uv ).xyz;
        //float3 col  =  float3( uv.x, uv.y, 0 );

        if( display_roads )
        {
            if( roadsType == 1 )
                col  =  add_main_roads_rectangle_2( col, tarPos );
            else if( roadsType == 2 )
                col  =  add_symmetry_roads_p3m1_colored( col, tarPos );
                //col  =  add_main_roads_hexagon_4( col, tarPos );
        }

        col  =  draw_sprite_quadratic( col, tarPos, camPos, vulVec, _VulTex, 1.0 );
        
        for( int k = 0; k < 16; k++ )
            if( _RocketsLive[k] > 0 )
            {
                float2 rocPos  =  float2( _RocketsState[k].x, _RocketsState[k].y );
                float2 rocVel  =  float2( _RocketsState[k].z, _RocketsState[k].w );
                rocVel  /=  length( rocVel );

                col  =  draw_sprite_linear( col, tarPos, rocPos, rocVel, _RocTex, 0.5 );
            }

        // if( pv1.x*vulVec.x + pv1.y*vulVec.y > length(pv1)*length(vulVec)*255/256 )
        //     col  =  brighter( col );

        if( fullscreen == false )
            col  =  lerp( float3(0,0,0), col, pow( clamp( (1.0-xy_rl)*32, 0, 1 ), 2 ) );

        return float4(col,1);
    }
    else
        return float4(0,0,0,1);
}