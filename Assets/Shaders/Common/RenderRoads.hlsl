float3 add_main_roads_rectangle_1( float3 col, float2 tarPos )
{
    float roadbr  =  0.30;
    float linebr  =  0.03;

    float dRx  =  x_distance_estimate_to_y_parameter_line( tarPos, 0.0       );
    float drx  =  x_distance_estimate_to_y_parameter_line( tarPos, 0.5*u2p.x );

    float dRy  =  y_distance_estimate_to_x_parameter_line( tarPos, 0.0       );
    float dry  =  y_distance_estimate_to_x_parameter_line( tarPos, 0.5*u2p.y );

    bool inRx  =  ( dRx < roadbr | drx < roadbr );
    bool inRy  =  ( dRy < roadbr | dry < roadbr );

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

float3 add_main_roads_rectangle_2( float3 col, float2 tarPos )
{
    float roadbr      =  0.30;
    float linebr      =  0.03;
    float roadfadebr  =  0.04;

    float dRx  =  x_distance_estimate_to_y_parameter_line( tarPos, 0.00       );
    float dmx  =  x_distance_estimate_to_y_parameter_line( tarPos, 0.25*u2p.x );
    float drx  =  x_distance_estimate_to_y_parameter_line( tarPos, 0.50*u2p.x );
    float dnx  =  x_distance_estimate_to_y_parameter_line( tarPos, 0.75*u2p.x );

    float dRy  =  y_distance_estimate_to_x_parameter_line( tarPos, 0.00       );
    float dmy  =  y_distance_estimate_to_x_parameter_line( tarPos, 0.25*u2p.w );
    float dry  =  y_distance_estimate_to_x_parameter_line( tarPos, 0.50*u2p.w );
    float dny  =  y_distance_estimate_to_x_parameter_line( tarPos, 0.75*u2p.w );

    float dx     =  min( dRx, min( dmx, min( drx, dnx ) ) );
    float dy     =  min( dRy, min( dmy, min( dry, dny ) ) );
    float dRoad  =  min( dx, dy );

    bool inRx  =  ( dRx < roadbr | drx < roadbr | dmx < roadbr | dnx < roadbr );
    bool inRy  =  ( dRy < roadbr | dry < roadbr | dmy < roadbr | dny < roadbr );

    if( inRx | inRy )
        col  =  float3(1,1,1)*0.05;
    else
        col  =  lerp( float3(1,1,1)*0.5, col, clamp( ( dRoad - roadbr ) / roadfadebr, 0, 1 ) );
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

float3 add_main_roads_hexagon_1( float3 col, float2 tarPos )
{
    float roadbr      =  0.30;
    float linebr      =  0.03;
    float roadfadebr  =  0.04;

    float2 k0  =  float2(  0.0,  sqrt(3)   ) * PI;
    float2 k1  =  float2( +1.5, -sqrt(3)/2 ) * PI;
    float2 k2  =  float2( -1.5, -sqrt(3)/2 ) * PI;

    float dRx  =  distance_from_parameter_line( tarPos, float2(0,0), k0 );
    float dR1  =  distance_from_parameter_line( tarPos, float2(0,0), k1 );
    float dR2  =  distance_from_parameter_line( tarPos, float2(0,0), k2 );

    float dRoad  =  min( dRx, min( dR1, dR2 ) );

    if( dRoad < roadbr )
        col  =  float3(1,1,1)*0.05;
    else
        col  =  lerp( float3(1,1,1)*0.5, col, clamp( ( dRoad - roadbr ) / roadfadebr, 0, 1 ) );

    if( dRoad < linebr )
        col  =  float3(1,1,1);

    return col;
}

float3 add_main_roads_hexagon_2( float3 col, float2 tarPos )
{
    float roadbr      =  0.30;
    float linebr      =  0.03;
    float roadfadebr  =  0.04;

    float2 k0  =  float2(  0.0,  sqrt(3)   ) * PI;
    float2 k1  =  float2( +1.5, -sqrt(3)/2 ) * PI;
    float2 k2  =  float2( -1.5, -sqrt(3)/2 ) * PI;

    float dR0  =  distance_from_parameter_line( tarPos, float2(0,0), k0 );
    float dR1  =  distance_from_parameter_line( tarPos, float2(0,0), k1 );
    float dR2  =  distance_from_parameter_line( tarPos, float2(0,0), k2 );

    float dr0  =  distance_from_parameter_line( tarPos, k0/2, k0 );
    float dr1  =  distance_from_parameter_line( tarPos, k1/2, k1 );
    float dr2  =  distance_from_parameter_line( tarPos, k2/2, k2 );

    float dR     =  min( dR0, min( dR1, dR2 ) );
    float dr     =  min( dr0, min( dr1, dr2 ) );
    float dRoad  =  min( dr, dR );

    bool in0  =  ( dR0 < roadbr | dr0 < roadbr );
    bool in1  =  ( dR1 < roadbr | dr1 < roadbr );
    bool in2  =  ( dR2 < roadbr | dr2 < roadbr );

    if( dRoad < roadbr )
        col  =  float3(1,1,1)*0.05;
    else
        col  =  lerp( float3(1,1,1)*0.5, col, clamp( ( dRoad - roadbr ) / roadfadebr, 0, 1 ) );
    
    if( in1 == false & in2 == false )
    {
        if( dR0 < linebr )
            col  =  float3(1.0,0.5,0.5);
        else if( dr0 < linebr )
            col  =  float3(0.0,0.5,0.5);
    }

    if( in2 == false & in0 == false )
    {
        if( dR1 < linebr )
        col  =  float3(0.5,1.0,0.5);
        else if( dr1 < linebr )
            col  =  float3(0.5,0.0,0.5);
    }

    if( in0 == false & in1 == false )
    {
        if( dR2 < linebr )
            col  =  float3(0.5,0.5,1.0);
        else if( dr2 < linebr )
            col  =  float3(0.5,0.5,0.0);
    }

    return col;
}

// float3 add_main_roads_hexagon_3( float3 col, float2 tarPos )
// {
//     float roadbr      =  0.30;
//     float linebr      =  0.03;
//     float roadfadebr  =  0.04;

//     float2 k0  =  float2(  0.0,  sqrt(3)     ) * PI;
//     float2 k1  =  float2( +1.5, -sqrt(3)*0.5 ) * PI;
//     float2 k2  =  float2( -1.5, -sqrt(3)*0.5 ) * PI;

//     float2 k0m  =  float2(  sqrt(3),      0.0 ) * PI;
//     float2 k1m  =  float2( -sqrt(3)*0.5, +1.5 ) * PI;
//     float2 k2m  =  float2( -sqrt(3)*0.5, -1.5 ) * PI;

//     float dR0  =  distance_from_parameter_line( tarPos, float2(0,0), k0m );
//     float dR1  =  distance_from_parameter_line( tarPos, float2(0,0), k1m );
//     float dR2  =  distance_from_parameter_line( tarPos, float2(0,0), k2m );

//     //float dr0  =  distance_from_parameter_line( tarPos, k0m/2, k0m );
//     //float dr1  =  distance_from_parameter_line( tarPos, k1m/2, k1m );
//     //float dr2  =  distance_from_parameter_line( tarPos, k2m/2, k2m );

//     float dR     =  min( dR0, min( dR1, dR2 ) );
//     float dr     =  min( dr0, min( dr1, dr2 ) );
//     float dRoad  =  min( dr, dR );

//     bool in0  =  ( dR0 < roadbr | dr0 < roadbr );
//     bool in1  =  ( dR1 < roadbr | dr1 < roadbr );
//     bool in2  =  ( dR2 < roadbr | dr2 < roadbr );

//     if( dRoad < roadbr )
//         col  =  float3(1,1,1)*0.05;
//     else
//         col  =  lerp( float3(1,1,1)*0.5, col, clamp( ( dRoad - roadbr ) / roadfadebr, 0, 1 ) );
    
//     if( in1 == false & in2 == false )
//     {
//         if( dR0 < linebr )
//             col  =  float3(1,0.5,0.5);
//         else if( dr0 < linebr )
//             col  =  float3(0,0.5,0.5);
//     }

//     if( in2 == false & in0 == false )
//     {
//         if( dR1 < linebr )
//         col  =  float3(0.5,1,0.5);
//         else if( dr1 < linebr )
//             col  =  float3(0.5,0,0.5);
//     }

//     if( in0 == false & in1 == false )
//     {
//         if( dR2 < linebr )
//             col  =  float3(0.5,0.5,1);
//         else if( dr2 < linebr )
//             col  =  float3(0.5,0.5,0);
//     }

//     return col;
// }

float3 add_main_roads_hexagon_4( float3 col, float2 tarPos )
{
    float roadbr      =  0.30;
    float linebr      =  0.03;
    float roadfadebr  =  0.04;

    float2 k0m  =  float2(  1.0,       0.00  ) * PI;
    float2 k1m  =  float2( -0.5, +sqrt(0.75) ) * PI;
    float2 k2m  =  float2( -0.5, -sqrt(0.75) ) * PI;

    float dRx  =  distance_from_parameter_line( tarPos, float2(0,0), k0m );
    float dR1  =  distance_from_parameter_line( tarPos, float2(0,0), k1m );
    float dR2  =  distance_from_parameter_line( tarPos, float2(0,0), k2m );

    float dRoad  =  min( dRx, min( dR1, dR2 ) );

    if( dRoad < roadbr )
        col  =  float3(1,1,1)*0.05;
    else
        col  =  lerp( float3(1,1,1)*0.5, col, clamp( ( dRoad - roadbr ) / roadfadebr, 0, 1 ) );

    if( dRoad < linebr )
        col  =  float3(1,1,1);

    return col;
}