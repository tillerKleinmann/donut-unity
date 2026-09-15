Shader "Custom/Confmets/hp_p3m1"
{
    Properties
    {
        [MainColor]       _BaseColor(  "Base Color",           Color  )  =  ( 1, 1, 1, 1 )
        [MainTexture]     _BaseMap(    "Base Map",             2D     )  =  "white"
        [VultureTexture]  _VulTex(     "Vulture Texture",      2D     )  =  "white"
        [RocketTexture]   _RocTex(     "Rocket Texture",       2D     )  =  "white"
        [DomainMatrix]    _DomMat(     "Domain Matrix",        Vector )  =  ( 6.2831853, 0, 0, 6.2831853 ) // ( b, s,  0,  h )
        [DupinParameters] _DupinPar(   "Dupin Parameters",     Vector )  =  ( 0.333, 0.333, 1.0, 1.0 )     // ( a, b, al, be )
        [RoadsDisp]       _RoadsDisp(  "Display Roads",        Float  )  =  1
        [RoadsType]       _RoadsType(  "Roads Type",           Float  )  =  1
        [ChartType]       _ChartType(  "Chart Type",           Float  )  =  1
        [VisionRadius]    _VisRad(     "Vision Radius",        Float  )  =  2
        [FullScreen]      _FullScreen( "Fullscreen",           Float  )  =  0
        [Accuracy]        _Accuracy(   "Accuracy",             Float  )  =  64
        [GSM]             _GSM(        "Geodesic Step Method", Float  )  =  1
        [CameraPosition]  _CamPos(     "Camera Position",      Vector )  =  ( 0, 0, 0, 0 )
        [CameraAngle]     _CamAng(     "Camera Angle",         Float  )  =  0
        [GameTime]        _GameTime(   "GameTime",             Float  )  =  0
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
            #include "Common/ConfMetsWaveVec.hlsl"

            static const float2  k1  =  dual_lattice_vector( 0, 1 );
            static const float2  k2  =  rot120( k1 );
            static const float2  k3  =  rot240( k1 );

            float mu( float2 p )
            { 
                return ( 5 + sip(p,k1) + sip(p,k2) + sip(p,k3) ) / 5;
            }

            float2 mu_grad( float2 p )
            {
                return  float2( sip_dx(p,k1) + sip_dx(p,k2) + sip_dx(p,k3),
                                sip_dy(p,k1) + sip_dy(p,k2) + sip_dy(p,k3)  ) / 5;
            }

            #include "Common/ConfMets_mu.hlsl"
            #include "Common/ConfMetsIncludes.hlsl"
            #include "Common/FragMain.hlsl"

            ENDHLSL
        }
    }
}
