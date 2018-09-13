Shader "Bump/002_parallax"
{
	Properties{
		_MainColor("MainColor",Color)=(1,1,1,1)
		_SpecularColor("SpecularColor",Color)=(1,1,1,1)
		_MainTex("MainTex",2D)="white"{}
		_BumpTex("BumpTex",2D)="bump"{}
		_HeightTex("HeightTex",2D)="black"{}
		_HeightScale("HeightScale",Range(0,0.2))=0.05
		_Gloss("Gloss",Range(8,255))=20
	}
	SubShader{
		Pass{
			Tags{"RenderType"="Opaque" "LightMode"="ForwardBase"}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#define PI 3.14159265359

			fixed4 _MainColor;
			fixed4 _SpecularColor;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			sampler2D _HeightTex;
			float _HeightScale;
			float _Gloss;

			struct a2v{
				float4 vertex:POSITION;
				float4 texcoord:TEXCOORD0;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			};
			//根据切线空间下的视角方向计算UV的采样偏移
			inline float2 CaculParallaxUVOffset(v2f i){
				//高度图高度采样
				float height=tex2D(_HeightTex,i.uv).r;
				float3 viewDir=normalize(i.viewDir);
				float2 offset=viewDir.xy/viewDir.z*height*_HeightScale;
				return offset;
			}

			v2f vert(a2v v){
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
				TANGENT_SPACE_ROTATION;
				o.lightDir=mul(rotation,ObjSpaceLightDir(v.vertex).xyz);
				o.viewDir=mul(rotation,ObjSpaceViewDir(v.vertex).xyz);

				return o;
			}

			fixed4 frag(v2f i):	SV_Target{
				fixed3 albedo=_MainColor.rgb*tex2D(_MainTex,i.uv);
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.rgb*albedo;
				//在对法线进行采样前，新进行UV偏移
				i.uv+=CaculParallaxUVOffset(i);
				fixed3 tangentNormalDir=UnpackNormal(tex2D(_BumpTex,i.uv));
				fixed3 tangentLightDir=normalize(i.lightDir);
				fixed3 tangentViewDir=normalize(i.viewDir);
				fixed3 halfDir=normalize(tangentViewDir+tangentLightDir); 
				//改进版 BRDF
				fixed3 diffuse=_LightColor0.rgb*ambient*max(0,saturate(dot(tangentNormalDir,tangentLightDir)))/PI;
				fixed3 specular=_LightColor0.rgb*_SpecularColor.rgb*pow(max(0,dot(tangentNormalDir,halfDir)),_Gloss)*max(0,saturate(dot(tangentNormalDir,tangentLightDir)))*(_Gloss+8)/(8*PI);
				
				return fixed4(ambient+diffuse+specular,1.0);
			}
			ENDCG
		}
	
	}
}
