#ifndef FRAMEWORK2D
#define FRAMEWORK2D

#include "UnityCG.cginc"
#include "FBM.cginc"

sampler2D _MainTex;
float4 _MainTex_ST;

struct a2v
{
	float4 vertex:POSITION;
	float2 texcoord:TEXCOORD0;
};

struct v2f{
	float2 uv:TEXCOORD0;
	float4 pos:SV_POSITION;
};

v2f vert(a2v v){
	v2f o;
	o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
	o.pos=UnityObjectToClipPos(v.vertex);
	return o;
}

float3 ProcessFrag(float2 uv);

float4 frag(v2f i):SV_Target{
	return float4(ProcessFrag(i.uv),1.0);
}

#endif
