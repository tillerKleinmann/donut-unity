float3 add_main_roads_rectangle( float3 col, float2 tarPos )
{
    float roadbr = 0.3;
    float linebr = 0.03;

    float dRx  =  x_distance_estimate_to_y_parameter_line( tarPos, 0 );
    float drx  =  x_distance_estimate_to_y_parameter_line( tarPos, 0.5*u2p.x );

    float dRy  =  y_distance_estimate_to_x_parameter_line( tarPos, 0 );
    float dry  =  y_distance_estimate_to_x_parameter_line( tarPos, 0.5*u2p.y );

    bool inRx = ( dRx < roadbr | drx < roadbr );
    bool inRy = ( dRy < roadbr | dry < roadbr );

    if( inRx | inRy )
        col  =  float3(1,1,1)*0.05;
    if( inRy == false )
    {
        if( dRx < linebr )
            col  =  float3(0,0,0);
        else if( drx < linebr )
            col  =  float3(1,0,0);
    }
    if( inRx == false )
    {
        if( dRy < linebr )
            col  =  float3(0,1,0);
        else if( dry < linebr )
            col  =  float3(0,0,1);
    }

    return col;
}

float3 add_main_roads_rectangle2( float3 col, float2 tarPos )
{
    float roadbr = 0.3;
    float linebr = 0.03;
    float roadfadebr = 0.05;

    float dRx  =  x_distance_estimate_to_y_parameter_line( tarPos, 0 );
    float dmx  =  x_distance_estimate_to_y_parameter_line( tarPos, 0.25*u2p.x );
    float drx  =  x_distance_estimate_to_y_parameter_line( tarPos, 0.50*u2p.x );
    float dnx  =  x_distance_estimate_to_y_parameter_line( tarPos, 0.75*u2p.x );

    float dRy  =  y_distance_estimate_to_x_parameter_line( tarPos, 0 );
    float dmy  =  y_distance_estimate_to_x_parameter_line( tarPos, 0.25*u2p.w );
    float dry  =  y_distance_estimate_to_x_parameter_line( tarPos, 0.50*u2p.w );
    float dny  =  y_distance_estimate_to_x_parameter_line( tarPos, 0.75*u2p.w );

    float dx  =  min( dRx, min( dmx, min( drx, dnx ) ) );
    float dy  =  min( dRy, min( dmy, min( dry, dny ) ) );
    float dRoad = min( dx, dy );

    bool inRx = ( dRx < roadbr | drx < roadbr | dmx < roadbr | dnx < roadbr );
    bool inRy = ( dRy < roadbr | dry < roadbr | dmy < roadbr | dny < roadbr );

    if( inRx | inRy )
        col  =  float3(1,1,1)*0.05;
    else
        col  =  lerp( float3(0.5,0.5,0.5), col, clamp( ( dRoad - roadbr ) / roadfadebr, 0, 1 ) );
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

float3 add_main_roads_hexagon( float3 col, float2 tarPos )
{
    float roadbr = 0.3;
    float linebr = 0.03;
    float roadfadebr = 0.05;

    tarPos  =  reset_to_parallelogram( tarPos );

    float dRx    =  distance_from_parameter_line( tarPos, float2(0,0), float2(        0.0,  1.0 ) * sqrt(3) * PI );
    float dRxyy  =  distance_from_parameter_line( tarPos, float2(0,0), float2( +sqrt(3)/2, -0.5 ) * sqrt(3) * PI );
    float dRyyx  =  distance_from_parameter_line( tarPos, float2(0,0), float2( -sqrt(3)/2, -0.5 ) * sqrt(3) * PI );

    float dRoad  =  min( dRx, min( dRxyy, dRyyx ) );
    //float dRoad = dRx;
    //float dRoad = dRxyy;
    //float dRoad = dRyyx;

    if( dRoad < roadbr )
        col  =  0.05*float3(1,1,1);
    else
        col  =  lerp( 0.5*float3(1,1,1), col, clamp( ( dRoad - roadbr ) / roadfadebr, 0, 1 ) );

    if( dRoad < linebr )
        col  =  float3(1,1,1);

    return col;
}