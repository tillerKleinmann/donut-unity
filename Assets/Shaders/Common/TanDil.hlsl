float tandil( float x, float la )
{
    float y  =  atan2( la*sin(x), cos(x) );
    
    return y - 2*PI*round((y-x)/(2*PI));
}

float tandil2( float x, float la )
{
    float y  =  2*atan2( la*sin(x/2), cos(x/2) );
    
    return y - 4*PI*round((y-x)/(4*PI));
}

float gendupin_x_sdiff( float p_x, float q_x, float r_y )
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

float gendupin_y_sdiff( float p_y, float q_y, float r_x )
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