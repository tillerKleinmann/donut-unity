Shader "Custom/Confmets/torusPsi"
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

            float  psi(      float2 p ){ return cos(p.x)/4; }
            float2 psi_grad( float2 p ){ return float2( -sin(p.x)/4, 0 ); }

            #include "Common/ConfMets_psi.hlsl"
            #include "Common/ConfMetsIncludes.hlsl"
            #include "Common/FragMain.hlsl"

            ENDHLSL
        }
    }
}
