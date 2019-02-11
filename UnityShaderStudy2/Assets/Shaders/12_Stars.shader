Shader "ZB/12_Stars"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			ZTest Always Cull off ZWrite off
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "ShaderLibs/FrameWork3D_DefaultRender.cginc"

			float4 ProcessRayMarch(float2 uv,float3 ro,float3 rd,inout float sceneDep,float4 sceneCol){
				float4 starCol=float4(Stars(rd,3,50),1.0);
				return starCol;
			}

			ENDCG
		}
	}
}
