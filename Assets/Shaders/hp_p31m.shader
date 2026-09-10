Shader "Custom/Confmets/hp_p31m"
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

            static const float  htri  =  2 / sqrt(3);

            static const float2  k0  =  float2(        0,  1 ) * htri;
            static const float2  k1  =  float2( +sqrt(3), -1 ) * htri / 2;
            static const float2  k2  =  float2( -sqrt(3), -1 ) * htri / 2;

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

            float skap( float2 p, float2 k )
            {
                return p.x*k.x + p.y*k.y;
            }

            float skapn( float2 p, float2 k )
            {
                return ( p.x*k.x*u2p.w + p.y*( k.y*u2p.x - k.x*u2p.y ) ) * 2*PI / ( u2p.x*u2p.w );
                //return ( k.x*( p.x*u2p.w - p.y*u2p.y ) + k.y*p.y*u2p.x ) * 2*PI / ( u2p.x*u2p.w );
            }

            float cop( float2 p, float2 k ){ return cos(skap(k,p)); }
            float sip( float2 p, float2 k ){ return sin(skap(k,p)); }

            static const float2  fp_a  =  4*PI/u2p.x;
            static const float2  fp_b  =  4*PI/u2p.x/sqrt(3);
            static const float2  fp_c  =  8*PI/u2p.x;

            float mu( float2 p )
            {
                return ( 8 + cop(p,k31_0) + cop(p,k31_1) + cop(p,k31_2) + 2*cos(p.x*fp_a)*cos(p.y*fp_b) + cos(x*fp_c) ) / 8;
            }
            float2 mu_grad( float2 p )
            {
                return float2(
                                k31_0.x*sip(p,k31_0) + k31_1.x*sip(p,k31_1) + k31_2.x*sip(p,k31_2) + 2*fp_a*sin(p.x*fp_a)*cos(p.y*fp_b) + fp_c*sin(p.x*fp_c),
                                k31_0.y*sip(p,k31_0) + k31_1.y*sip(p,k31_1) + k31_2.y*sip(p,k31_2) + 2*fp_b*cos(p.x*fp_a)*sin(p.y*fp_b)
                            ) * ( -1.0 / 5 );
            }

            #include "Common/ConfMets_mu.hlsl"
            #include "Common/ConfMetsIncludes.hlsl"
            #include "Common/FragMain.hlsl"

            ENDHLSL
        }
    }
}
