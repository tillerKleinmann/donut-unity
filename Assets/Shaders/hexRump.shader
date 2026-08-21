Shader "Custom/Confmets/hexRump"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white"
        [VultureTexture] _VulTex("Vulture Texture", 2D) = "white"
        [RocketTexture] _RocTex("Rocket Texture", 2D) = "white"
        [DomainMatrix] _DomMat( "Domain Matrix", Vector )  =  (6.2831853,0,0,6.2831853)
        [DupinParameters] _DupinPar("Dupin Parameters", Vector)  =  (0.333, 0.333, 1.0, 1.0) // ( a, b, al , be )
        [RoadsDisp] _RoadsDisp("Display Roads", Float)  =  1
        [RoadsType] _RoadsType("Roads Type", Float)  =  1
        [ChartType] _ChartType("Chart Type", Float)  =  1
        [VisionRadius] _VisRad("Vision Radius", Float)  =  2
        [FullScreen] _FullScreen("Fullscreen", Float)  =  0
        [Accuracy] _Accuracy("Accuracy", Float)  =  64
        [GSM] _GSM("Geodesic Step Method", Float)  =  1
        [CameraPosition] _CamPos("Camera Position", Vector)  =  (0, 0, 0, 0)
        [CameraAngle] _CamAng("Camera Angle", Float)  =  0
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

            float skap( float2 p, float2 k ){ return p.x*k.x + p.y*k.y; }

            float cop( float2 p, float2 k ){ return cos(skap(k,p)); }
            float sip( float2 p, float2 k ){ return sin(skap(k,p)); }

            float  mu(      float2 p ){ return ( 5 + sip(p,k0) + sip(p,k1) + sip(p,k2) ) / 5; }
            float2 mu_grad( float2 p ){ return float2( k0.x*cop(p,k0) + k1.x*cop(p,k1) + k2.x*cop(p,k2), k0.y*cop(p,k0) + k1.y*cop(p,k1) + k2.y*cop(p,k2) ) * ( 1.0 / 5 ); }

            #include "Common/ConfMets_mu.hlsl"
            #include "Common/ConfMetsIncludes.hlsl"
            #include "Common/FragMain.hlsl"

            ENDHLSL
        }
    }
}
