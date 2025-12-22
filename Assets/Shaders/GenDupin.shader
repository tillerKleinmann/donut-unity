Shader "Custom/Confmets/gendupin"
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
        [DupinParameters] _DupinPar("Dupin Parameters", Vector)  =  (0.5, 0.5, 1.0, 1.0)
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

            #include "Common/ShaderPreamble.hlsl"

            float  confun(      float2 p ){ return -log( 1 + dupinPar.x*cos(p.x/dupinPar.z) + dupinPar.y*cos(p.y/dupinPar.w) ); }
            float2 confun_grad( float2 p ){ return float2( dupinPar.x*sin(p.x/dupinPar.z), dupinPar.y*sin(p.y/dupinPar.w)/7 ) / ( dupinPar.x*cos(p.x/dupinPar.z) + dupinPar.y*cos(p.y/dupinPar.w) ); }
            float  confun_lap(  float2 p ){ return 0; }// not yet implemented...

            #include "Common/ConfMetsShader.hlsl"

            ENDHLSL
        }
    }
}
