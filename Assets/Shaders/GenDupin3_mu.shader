Shader "Custom/Confmets/gendupin3_mu"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white"
        [DomainMatrix] _DomMat( "Domain Matrix", Vector )  =  (6.2831853,0,0,6.2831853)
        [CameraPosition] _CamPos("Camera Position", Vector)  =  (0, 0, 0, 0)
        [CameraAngle] _CamAng("Camera Angle", Float)  =  0
        [VisionRadius] _VisRad("Vision Radius", Float)  =  2
        [FullScreen] _FullScreen("Fullscreen", Float)  =  0
        [Accuracy] _Accuracy("Accuracy", Float)  =  64
        [GSM] _GSM("Geodesic Step Method", Float)  =  1
        [DupinParameters] _DupinPar("Dupin Parameters", Vector)  =  (0.333, 0.333, 1.0, 1.0) // ( a, b, al , be )
        [ChartType] _ChartType("Chart Type", Float)  =  1
        [VultureTexture] _VulTex("Vulture Texture", 2D) = "white"
        [RocketTexture] _RocTex("Rocket Texture", 2D) = "white"
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

            #include "Common/DupinShaderPreamble.hlsl"

            float psqueeze3( float x )
            {
                return x*(3-x*x)/2;
            }

            float psqueeze3_d( float x )
            {
                return (1-x*x)*3/2;
            }

            float mu( float2 p )
            {
                return 1 + dpa*psqueeze3(cos(p.x/dpal)) + dpb*psqueeze3(cos(p.y/dpbe));
            }
            float2 mu_grad( float2 p )
            {
                return float2(  -(dpa/dpal)*sin(p.x/dpal)*psqueeze3_d(cos(p.x/dpal)),
                                -(dpb/dpbe)*sin(p.y/dpbe)*psqueeze3_d(cos(p.y/dpbe))    );
            }

            #include "Common/ConfMets_mu.hlsl"
            #include "Common/ConfMetsIncludes.hlsl"
            #include "Common/FragMain.hlsl"

            ENDHLSL
        }
    }
}
