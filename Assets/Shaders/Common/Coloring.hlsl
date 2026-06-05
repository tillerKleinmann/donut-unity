float br( float c )
{
    return c*(1+c-c*c);
}

float3 brighter( float3 col )
{
    return float3( br(col.x), br(col.y), br(col.z) );
}