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

float sqz_td( float x, float la )
{
    return tandil( x * (PI/2), la ) / (PI/2);
}

float sqz_td_d( float x, float la )
{
    return 2*la / ( 1 + pow(la,2) + ( 1 - pow(la,2) )*cos(2*x*(PI/2)) );
}