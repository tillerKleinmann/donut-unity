Shader "Custom/Confmets/hp_p6"
{
    Properties
    {
        [MainColor]       _BaseColor(  "Base Color",           Color  )  =  ( 1, 1, 1, 1 )
        [MainTexture]     _BaseMap(    "Base Map",             2D     )  =  "white"
        [VultureTexture]  _VulTex(     "Vulture Texture",      2D     )  =  "white"
        [RocketTexture]   _RocTex(     "Rocket Texture",       2D     )  =  "white"
        [DomainMatrix]    _DomMat(     "Domain Matrix",        Vector )  =  ( 6.2831853, 0, 0, 6.2831853 ) // ( b, s,  0,  h )
        [DupinParameters] _DupinPar(   "Dupin Parameters",     Vector )  =  ( 0.333, 0.333, 1.0, 1.0 )     // ( a, b, al, be )
        [RoadsDisp]       _RoadsDisp(  "Display Roads",        Float  )  =  1
        [RoadsType]       _RoadsType(  "Roads Type",           Float  )  =  1
        [ChartType]       _ChartType(  "Chart Type",           Float  )  =  1
        [VisionRadius]    _VisRad(     "Vision Radius",        Float  )  =  2
        [FullScreen]      _FullScreen( "Fullscreen",           Float  )  =  0
        [Accuracy]        _Accuracy(   "Accuracy",             Float  )  =  64
        [GSM]             _GSM(        "Geodesic Step Method", Float  )  =  1
        [CameraPosition]  _CamPos(     "Camera Position",      Vector )  =  ( 0, 0, 0, 0 )
        [CameraAngle]     _CamAng(     "Camera Angle",         Float  )  =  0
        [GameTime]        _GameTime(   "GameTime",             Float  )  =  0
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GlobalSamplers.hlsl"

            #include "Common/ConfMetsShaderPreamble.hlsl"

            static const float2 k0 = float2(  0,  2/sqrt(3) );
            static const float2 k1 = float2( +1, -1/sqrt(3) );
            static const float2 k2 = float2( -1, -1/sqrt(3) );
            static const float2 k3 = 2*k0;
            static const float2 k4 = 2*k1;
            static const float2 k5 = 2*k2;
            static const float2 k6 = float2(  2,  0         );
            static const float2 k7 = float2( -1, -3/sqrt(3) );
            static const float2 k8 = float2( -1, +3/sqrt(3) );

            static const float2 k3m = k3/2;
            static const float2 k4m = k4/2;
            static const float2 k5m = k5/2;
            static const float2 k6m = k6/2;
            static const float2 k7m = k7/2;
            static const float2 k8m = k8/2;

            float2 dual_vec( int k, int l )
            {
                return float2( k / dp_b, l / dp_h  -  k * (dp_s/(dp_b*dp_h)) );
            }

            float2 rot120( float2 p )
            {
                return float2( -0.5*p.x - sqrt(0.75)*p.y, -0.5*p.y + sqrt(0.75)*p.x );
            }

            float2 rot240( float2 p )
            {
                return float2( -0.5*p.x + sqrt(0.75)*p.y, -0.5*p.y - sqrt(0.75)*p.x );
            }

            static const float2  k31_0  =  dual_vec( 3, 1 );
            static const float2  k31_1  =  rot120( k31_0 );
            static const float2  k31_2  =  rot240( k31_0 );

            float skap( float2 p, float2 k ){ return p.x*k.x + p.y*k.y; }

            float cop( float2 p, float2 k ){ return cos(skap(k,p)); }
            float sip( float2 p, float2 k ){ return sin(skap(k,p)); }

            float  mu(      float2 p )
            {
                return ( 9 + cop( p, k3m   ) + cop( p, k4m   ) + cop( p, k5m   )
                           + cop( p, k31_0 ) + cop( p, k31_1 ) + cop( p, k31_2 ) ) / 9;
            }

            float2 mu_grad( float2 p )
            {
                return float(  k3m.x  *sip( p, k3m   ) + k4m.x  *sip( p, k4m   ) + k5m.x  *sip( p, k5m   ) +
                               k31_0.x*sip( p, k31_0 ) + k31_1.x*sip( p, k31_1 ) + k31_2.x*sip( p, k31_2 ),
                               k3m.y  *sip( p, k3m   ) + k4m.y  *sip( p, k4m   ) + k5m.y  *sip( p, k5m   ) +
                               k31_0.y*sip( p, k31_0 ) + k31_1.y*sip( p, k31_1 ) + k31_2.y*sip( p, k31_2 )   )
                        *
                        ( -1.0 / 9 );
            }

            #include "Common/ConfMets_mu.hlsl"
            #include "Common/ConfMetsIncludes.hlsl"
            #include "Common/FragMain.hlsl"

            ENDHLSL
        }
    }
}
