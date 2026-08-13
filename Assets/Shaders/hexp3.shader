Shader "Custom/Confmets/hexp3"
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

            #include "Common/ConfMetsShaderPreamble.hlsl"

            static const float htri = 2/sqrt(3);

            static const float2 k0 = float2( 0, 1 ) * htri;
            static const float2 k1 = float2( +sqrt(3), -1 ) * htri/2;
            static const float2 k2 = float2( -sqrt(3), -1 ) * htri/2;
            static const float2 k3 = float2( 0, 2 ) * htri/2;
            static const float2 k4 = float2( +sqrt(3), -1 ) * htri/2;
            static const float2 k5 = float2( -sqrt(3), -1 ) * htri/2;
            static const float2 k6 = float2( sqrt(3), 0 ) * htri/2;
            static const float2 k7 = float2( -sqrt(3)/2, -1.5 ) * htri/2;
            static const float2 k8 = float2( -sqrt(3)/2, +1.5 ) * htri/2;

            float skap( float2 p, float2 k ){ return p.x*k.x + p.y*k.y; }

            float cop( float2 p, float2 k ){ return cos(skap(k,p)); }
            float sip( float2 p, float2 k ){ return sin(skap(k,p)); }

            float  mu(      float2 p ){ return ( 7 + sip(p,k3) + sip(p,k4) + sip(p,k5) + sip(p,k6) + sip(p,k7) + sip(p,k8) ) / 7; }
            float2 mu_grad( float2 p ){ return float2(  k3.x*cop(p,k3) + k4.x*cop(p,k4) + k5.x*cop(p,k5) + k6.x*cop(p,k6) + k7.x*cop(p,k7) + k8.x*cop(p,k8),
                                                        k3.y*cop(p,k3) + k4.y*cop(p,k4) + k5.y*cop(p,k5) + k6.y*cop(p,k6) + k7.y*cop(p,k7) + k8.y*cop(p,k8)  ) / 7; }

            #include "Common/ConfMets_mu.hlsl"
            #include "Common/ConfMetsIncludes.hlsl"
            #include "Common/FragMain.hlsl"

            ENDHLSL
        }
    }
}
