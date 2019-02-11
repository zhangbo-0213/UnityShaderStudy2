Shader "ZB/11_RDTest"
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
				sceneCol.xyz=rd;
				return sceneCol;
			}

			ENDCG
		}
	}
}
