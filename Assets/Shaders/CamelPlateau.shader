Shader "Custom/Confmets/camelPlateau"
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

            #include "Common/ShaderPreamble.hlsl"

            float  confun(      float2 p ){ return 0.5 + cos(p.x)*(3-pow(cos(p.x),2))*cos(p.y)*(3-pow(cos(p.y),2))/8; }
            float2 confun_grad( float2 p ){ return float2( -3*sin(p.x)*(1-pow(cos(p.x),2))*cos(p.y)*(3-pow(cos(p.y),2))/8, -3*sin(p.y)*(1-pow(cos(p.y),2))*cos(p.x)*(3-pow(cos(p.x),2))/8 ); }
            float  confun_lap(  float2 p ){ return 9*cos(p.x)*(pow(cos(p.x),2)-1)/8; } // unused yet ... and not written yet...

            #include "Common/ConfMetsShader.hlsl"

            ENDHLSL
        }
    }
}
