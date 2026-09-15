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
            #include "Common/ConfMetsWaveVec.hlsl"

            static const float  a1  =  2*PI / u2p.x;
            static const float  a2  =  2*PI / u2p.x * sqrt(3);
            static const float  a3  =  4*PI / u2p.x;
            static const float  a4  =  4*PI / u2p.x;
            static const float  a5  =  4*PI / u2p.x / sqrt(3);
            static const float  a6  =  8*PI / u2p.x / sqrt(3);

            float mu( float2 p )
            {
                return  ( 8 + 2*cos(p.x*a4)*cos(p.y*a5) + cos(p.y*a6) + 2*sin(p.x*a1)*cos(p.y*a2) - sin(p.x*a3) ) / 8;
            }
            float2 mu_grad( float2 p )
            {
                return  float2( -2*a4*sin(p.x*a4)*cos(p.y*a5)                  + 2*a1*cos(p.x*a1)*cos(p.y*a2) - a3*cos(p.x*a3),
                                -2*a5*cos(p.x*a4)*sin(p.y*a5) - a6*sin(p.y*a6) - 2*a2*sin(p.x*a1)*sin(p.y*a2)                   ) / 8;
            }

            #include "Common/ConfMets_mu.hlsl"
            #include "Common/ConfMetsIncludes.hlsl"
            #include "Common/FragMain.hlsl"

            ENDHLSL
        }
    }
}
