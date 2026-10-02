// float gendupin_x_sdiff( float p_x, float q_x, float r_y, float a, float b )
// {
//     float c   =  1 + b*cos( r_y * 2*PI / u2p.w );
//     float la  =  sqrt( (c-a) / (c+a) );
//     float C   =  2*PI / ( u2p.x * sqrt( pow(c,2) + pow(b,2) ) );

//     p_x  =  p_x - u2p.x*round( p_x / u2p.x );
//     q_x  =  q_x - u2p.y*round( q_x / u2p.y );

//     float p_sx  =  tandil2( p_x * 2*PI / dpal, la );
//     float q_sx  =  tandil2( q_x / dpal, la );

//     return C * ( q_sx - p_sx );
// }

float dpal  =  u2p.x / (2*PI);
float dpbe  =  u2p.w / (2*PI);

float gendupin_x_sdiff( float p_x, float q_x, float r_y, float dpa, float dpb )
{
    float c   =  1 + dpb*cos( r_y / dpbe );
    float la  =  sqrt( (c-dpa) / (c+dpa) );
    float C   =  dpal / sqrt( pow(c,2) + pow(dpb,2) );

    p_x  =  p_x - dpAl*round( p_x / dpAl );
    q_x  =  q_x - dpAl*round( q_x / dpAl );

    float p_sx  =  tandil2( p_x / dpal, la );
    float q_sx  =  tandil2( q_x / dpal, la );

    return C * ( q_sx - p_sx );
}

float gendupin_y_sdiff( float p_y, float q_y, float r_x, float dpa, float dpb )
{
    float c   =  1 + dpb*cos( r_x / dpal );
    float la  =  sqrt( (c-dpb) / (c+dpb) );
    float C   =  dpbe / sqrt( pow(c,2) + pow(dpa,2) );

    p_y  =  p_y - dpBe*round( p_y / dpBe );
    q_y  =  q_y - dpBe*round( q_y / dpBe );

    float p_sy  =  tandil2( p_y / dpbe, la );
    float q_sy  =  tandil2( q_y / dpbe, la );

    return C * ( q_sy - p_sy );
}