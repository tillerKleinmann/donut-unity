Shader "Custom/Confmets/torus_mu"
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

            //float  mu(      float2 p ){ return 1 - cos(p.y*2/sqrt(3))/2; }
            //float2 mu_grad( float2 p ){ return float2( 0, sin(p.y*2/sqrt(3))/sqrt(3) ); }
            float  mu(      float2 p ){ return ( 2 - cos(p.y*sqrt(3)) ) / 3; }
            float2 mu_grad( float2 p ){ return float2( 0, -sin(p.y*sqrt(3)) / sqrt(3) ); }

            #include "Common/ConfMets_mu.hlsl"
            #include "Common/GeoProp.hlsl"
            #include "Common/FunDom.hlsl"
            #include "Common/SpriteRendering.hlsl"
            #include "Common/RenderRoads.hlsl"
            #include "Common/Coloring.hlsl"
            #include "Common/FragMain.hlsl"

            ENDHLSL
        }
    }
}
