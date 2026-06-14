float3 add_main_roads_rectangle( float3 col, float2 tarPos )
{
    float2 tarPos1  =  reset_to_parallelogram( tarPos );
    float2 tarPos2  =  reset_to_parallelogram_shifted( tarPos );

    float dRx  =  confac( float2(0,tarPos1.y) )  * abs(tarPos1.x);
    float drx  =  confac( float2(PI,tarPos2.y) ) * abs(tarPos2.x-PI);
    float dRy  =  confac( float2(tarPos1.x,0) )  * abs(tarPos1.y);
    float dry  =  confac( float2(tarPos2.x,PI) ) * abs(tarPos2.y-PI);

    float roadbr = 0.3;
    float linebr = 0.03;

    if( dRx < roadbr )
        col  =  float3(0,0,0);
    if( drx < roadbr )
        col  =  float3(0,0,0);
    if( dRy < roadbr )
        col  =  float3(0,0,0);
    if( dry < roadbr )
        col  =  float3(0,0,0);
    if( dRx < linebr & dRy > roadbr & dry > roadbr  )
        col  =  float3(1,0,0);
    if( drx < linebr & dRy > roadbr & dry > roadbr  )
        col  =  float3(0,1,0);
    if( dRy < linebr & dRx > roadbr & drx > roadbr  )
        col  =  float3(0,0,1);
    if( dry < linebr & dRx > roadbr & drx > roadbr  )
        col  =  float3(1,1,0);

    return col;
}

float3 add_main_roads_rectangle2( float3 col, float2 tarPos )
{
    float2 tarPos1  =  reset_to_parallelogram( tarPos );
    float2 tarPos2  =  reset_to_parallelogram_shifted( tarPos );

    float dRx  =  confac( float2(         0, tarPos1.y ) ) * abs( tarPos1.x );
    float drx  =  confac( float2( 0.5*u2p.x, tarPos2.y ) ) * abs( tarPos2.x - 0.5*u2p.x );
    float dRy  =  confac( float2( tarPos1.x,        0  ) ) * abs( tarPos1.y );
    float dry  =  confac( float2( tarPos2.x, 0.5*u2p.w ) ) * abs( tarPos2.y - 0.5*u2p.w );

    float dmx  =  confac( float2(  0.25*u2p.x, tarPos1.y ) ) * abs( tarPos1.x - 0.25*u2p.x );
    float dnx  =  confac( float2( -0.25*u2p.x, tarPos1.y ) ) * abs( tarPos1.x + 0.25*u2p.x );
    float dmy  =  confac( float2( tarPos1.x,  0.25*u2p.w ) ) * abs( tarPos1.y - 0.25*u2p.w );
    float dny  =  confac( float2( tarPos1.x, -0.25*u2p.w ) ) * abs( tarPos1.y + 0.25*u2p.w );

    float roadbr = 0.3;
    float linebr = 0.03;

    bool inRx = ( dRx < roadbr | drx < roadbr | dmx < roadbr | dnx < roadbr );
    bool inRy = ( dRy < roadbr | dry < roadbr | dmy < roadbr | dny < roadbr );

    if( inRx | inRy )
        col  =  float3(1,1,1)*0.05;
    if( inRy == false )
    {
        if( dRx < linebr )
            col  =  float3(0,0,0);
        else if( drx < linebr )
            col  =  float3(1,0,1);
        else if( dmx < linebr )
            col  =  float3(0,1,1);
        else if( dnx < linebr )
            col  =  float3(1,1,0);
    }
    if( inRx == false )
    {
        if( dRy < linebr )
            col  =  float3(1,1,1);
        else if( dry < linebr )
            col  =  float3(0,1,0);
        else if( dmy < linebr )
            col  =  float3(0,0,1);
        else if( dny < linebr )
            col  =  float3(1,0,0);
    }

    return col;
}