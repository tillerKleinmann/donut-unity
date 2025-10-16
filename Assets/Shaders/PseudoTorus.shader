Shader "Custom/PseudoTorus"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white"
        [CameraPosition] _CamPos("Camera Position", Vector)  =  (0, 0, 0, 0)
        [CameraAngle] _CamAng("Camera Angle", Float)  =  0
        [VisionRadius] _VisRad("Vision Radius", Float)  =  2
        [Accuracy] _Accuracy("Accuracy", Float)  =  64
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

            #include "ShaderPreamble.hlsl"

            float      confun( float2 p ){ return cos(p.x)/4; }
            float2   confun_d( float2 p ){ return float2( -sin(p.x)/4, 0 ); }
            float  confun_lap( float2 p ){ return -cos(p.x)/4; }

            #include "ConfMetsShader.hlsl"

            ENDHLSL
        }
    }
}
