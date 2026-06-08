float3 draw_sprite_centered( float3 col, float2 pixPos, float2 sprVec, Texture2D Tex, float sprScale )
{
    pixPos *= confac(pixPos) / sprScale;

    pixPos  =  mul( pixPos, float2x2( -sprVec.x, -sprVec.y, -sprVec.y, sprVec.x ) );

    float2 spr_uv = pixPos + float2(0.5,0.5);

    float4 sprCol  =  SAMPLE_TEXTURE2D( Tex, sampler_LinearClamp, spr_uv );

    return lerp( col, sprCol.xyz, sprCol.w );
}

float3 draw_sprite_linear( float3 col, float2 pixPos, float2 sprPos, float2 sprVec, Texture2D Tex, float sprScale )
{
    float2 pix2spr = pixPos - sprPos;
    
    pix2spr = reset_to_parallelogram( pix2spr );

    pix2spr *= confac(sprPos) / sprScale;

    pix2spr  =  mul( pix2spr, float2x2( -sprVec.x, -sprVec.y, -sprVec.y, sprVec.x ) );

    float2 spr_uv = pix2spr + float2(0.5,0.5);

    float4 sprCol  =  SAMPLE_TEXTURE2D( Tex, sampler_LinearClamp, spr_uv );

    return lerp( col, sprCol.xyz, sprCol.w );
}

float3 draw_sprite_quadratic( float3 col, float2 pixPos, float2 sprPos, float2 sprVec, Texture2D Tex, float sprScale )
{
    float2  pix2spr  =  pixPos - sprPos;
    
    pix2spr = reset_to_parallelogram( pix2spr );

    float2  spr_pv[2]  =  { sprPos, pix2spr };
    float2  pix2spr_q  =  pix2spr + 0.5 * christoffel( spr_pv );

    pix2spr_q *= confac(sprPos);

    pix2spr_q  =  mul( pix2spr_q, float2x2( -sprVec.x, -sprVec.y, -sprVec.y, sprVec.x ) ) / sprScale;

    float2 spr_uv  =  pix2spr_q + float2(0.5,0.5);

    float4 sprCol  =  SAMPLE_TEXTURE2D( Tex, sampler_LinearClamp, spr_uv );

    if( length(pix2spr) > 1.0 )
        sprCol.w = 0;

    return lerp( col, sprCol.xyz, sprCol.w );
}