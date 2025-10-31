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
    float4 _DomMat;
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

float4 _RocketsState[16];
float  _RocketsLive[16];

static const float   R  =  _VisRad;
static const int   itn  =  int( _Accuracy );
static const int   gsm  =  int( _GSM );

static const float4   u2p = float4( _DomMat.x, _DomMat.y, 0, _DomMat.w );
static const float2x2 usq2plg = transpose( float2x2( u2p.x, u2p.y, 0, u2p.w ) );
static const float2x2 plg2usq = transpose( float2x2( 1/u2p.x, -u2p.y/(u2p.x*u2p.w), 0, 1/u2p.w ) );

static const float2 camPos = float2( _CamPos.x, _CamPos.y );
static const float2 vulVec = float2( _CamPos.z, _CamPos.w );

static const float camRad  =  _CamAng * (PI/180);