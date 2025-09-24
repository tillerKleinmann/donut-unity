Shader "Custom/DonutShader"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white"
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }
            
            static const float  Pi = 3.14159;
            static const float   R = 2;
            static const float   r = 1;
            static const float   L = 2*Pi;
            static const int   itn = 64;

            // [begin](copy from https://www.shadertoy.com/view/ltXfRr)
            float2 RR; // see more about aniso x16 here: https://www.shadertoy.com/view/ltXfRr

            void torus_geodesic_euler_step( float2 pv[2], float dt, out float2 pv_next[2] )
            {
                float A  =  ( R + r*cos(pv[0].y) ) / r;
                
                float2 Ga_p_v_v  =  ( sin(pv[0].y) * pv[1].x ) * float2( -2 * pv[1].y / A, pv[1].x * A );
                
                pv_next[0]  =  pv[0] + dt*pv[1];
                pv_next[1]  =  pv[1] - dt*Ga_p_v_v;
            }

            float confun( float2 p )
            {
                return cos( p.y );
            }

            float2 confun_d( float2 p )
            {
                return float2( 0, -sin( p.y ) );
            }

            float confun_lap( float2 p )
            {
                return -cos( p.y );
            }

            float confun_exp( float2 p )
            {
                return exp( confun( p ) );
            }

            float confun_exp2( float2 p )
            {
                return exp( 2*confun( p ) );
            }

            float2 christoffel( float2 pv[2] )
            {
                float2 cfd  =  confun_d( pv[0] );

                float a  =  pow( pv[1].x, 2 );
                float b  =  2 * pv[1].x * pv[1].y;
                float c  =  pow( pv[1].y, 2 );

                return float2( cfd.x*(a-c) + cfd.y*b, cfd.y*(c-a) + cfd.x*b );
            }

            float curvature( float2 p )
            {
                return -confun_lap( p ) / confun_exp2( p );
            }

            void geodesic_euler_step( float2 pv[2], float dt, out float2 pv_next[2] )
            {
                pv_next[0]  =  pv[0] + dt*pv[1];
                pv_next[1]  =  pv[1] - dt*christoffel(pv);
            }
            
            half4 frag( Varyings IN ) : SV_Target
            {
                float2 xy  =  IN.uv;
                
                xy  =  2*xy - float2(1,1);
                
                float ph0  =  _Time.y;
                
                if( pow(xy.x,2) + pow(xy.y,2) < 1.0 )
                {
                    xy  =  xy * L;

                    float2 pv[2];
                    pv[0]  =  float2( 0, ph0 );
                    //pv[1]  =  xy / float2( R + r*cos(pv[0].y), r );
                    pv[1]  =  xy / confun_exp(pv[0]);
                    
                    float2 pv_next[2];
                    
                    float dt  =  1 / float(itn);
                    
                    for( int i = 0; i < itn; i++ )
                    {
                        //torus_geodesic_euler_step( pv, dt, pv_next );
                        geodesic_euler_step( pv, dt, pv_next );
                        pv  =  pv_next;
                    }
                    
                    float2 uv  =  pv_next[0] / ( 2*Pi );
                    
                    uv.y  +=  0.5;
                    
                    float3 col  =  SAMPLE_TEXTURE2D( _BaseMap, sampler_BaseMap, uv ).xyz;
                    
                    return float4( col, 1 );
                }
                else
                    return float4( 0, 0, 0, 1 );
            }
            ENDHLSL
        }
    }
}
