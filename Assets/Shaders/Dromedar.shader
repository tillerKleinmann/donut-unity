Shader "Custom/Confmets/dromedar"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white"
        [CameraPosition] _CamPos("Camera Position", Vector)  =  (0, 0, 0, 0)
        [CameraAngle] _CamAng("Camera Angle", Float)  =  0
        [VisionRadius] _VisRad("Vision Radius", Float)  =  2
        [Accuracy] _Accuracy("Accuracy", Float)  =  64
        [GSM] _GSM("Geodesic Step Method", Float)  =  1
        [VultureTexture] _VulTex("Vulture Texture", 2D) = "white"
        [RocketTexture] _RocTex("Rocket Texture", 2D) = "white"
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
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/GlobalSamplers.hlsl"

            #include "ShaderPreamble.hlsl"

            float      confun( float2 p ){ return (1-cos(p.x))*(1-cos(p.y)) / 4; }
            float2   confun_d( float2 p ){ return float2( sin(p.x)*(1-cos(p.y)), (1-cos(p.x))*sin(p.y) ) / 4; }
            float  confun_lap( float2 p ){ return ( -2*cos(p.x)*cos(p.y) + cos(p.x) + cos(p.y) ) / 4; }

            #include "ConfMetsShader.hlsl"

            ENDHLSL
        }
    }
}
