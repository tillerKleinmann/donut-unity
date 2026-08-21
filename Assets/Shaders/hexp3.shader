Shader "Custom/Confmets/hexp3"
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

            static const float2 k0 = float2(  0,  2/sqrt(3) );
            static const float2 k1 = float2( +1, -1/sqrt(3) );
            static const float2 k2 = float2( -1, -1/sqrt(3) );
            static const float2 k3 = 2*k0;
            static const float2 k4 = 2*k1;
            static const float2 k5 = 2*k2;
            static const float2 k6 = float2(  2,  0         );
            static const float2 k7 = float2( -1, -3/sqrt(3) );
            static const float2 k8 = float2( -1, +3/sqrt(3) );

            static const float2 k3m = k3/2;
            static const float2 k4m = k4/2;
            static const float2 k5m = k5/2;
            static const float2 k6m = k6/2;
            static const float2 k7m = k7/2;
            static const float2 k8m = k8/2;

            float skap( float2 p, float2 k ){ return p.x*k.x + p.y*k.y; }

            float cop( float2 p, float2 k ){ return cos(skap(k,p)); }
            float sip( float2 p, float2 k ){ return sin(skap(k,p)); }

            float  mu(      float2 p )
            {
                return ( 9 + sip(p,k3m) + sip(p,k4m) + sip(p,k5m)
                           + sip(p,k6m) + sip(p,k7m) + sip(p,k8m) ) / 9;
            }

            float2 mu_grad( float2 p )
            {
                return float2( k3m.x*cop(p,k3m) + k4m.x*cop(p,k4m) + k5m.x*cop(p,k5m) +
                               k6m.x*cop(p,k6m) + k7m.x*cop(p,k7m) + k8m.x*cop(p,k8m),
                               k3m.y*cop(p,k3m) + k4m.y*cop(p,k4m) + k5m.y*cop(p,k5m) +
                               k6m.y*cop(p,k6m) + k7m.y*cop(p,k7m) + k8m.y*cop(p,k8m)   ) / 9;
            }

            #include "Common/ConfMets_mu.hlsl"
            #include "Common/ConfMetsIncludes.hlsl"
            #include "Common/FragMain.hlsl"

            ENDHLSL
        }
    }
}
