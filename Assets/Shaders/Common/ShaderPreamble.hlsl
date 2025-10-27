struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
};

struct Varyings
{
    float4 positionHCS : SV_POSITION;
    float2 uv : TEXCOORD0;
};

TEXTURE2D(_BaseMap);
TEXTURE2D(_VulTex);
TEXTURE2D(_RocTex);

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    float4 _BaseMap_ST;
    float  _CamAng;
    float  _VisRad;
    float  _Accuracy;
    float  _GSM;
    float4 _CamPos;
CBUFFER_END

Varyings vert(Attributes IN)
{
    Varyings OUT;
    OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
    OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
    return OUT;
}

uniform float2 position;
uniform float2 direction;

float4 _RocketsState[16];
float  _RocketsLive[16];