Shader "Bump/003_relief"
{
	Properties
	{
		_MainColor("MaincColor",Color)=(1,1,1,1)
		_SpecularColor("SpecualrColor",Color)=(1,1,1,1)
		_MainTex("MainTex",2D)="white"{}
		_BumpTex("BumpTex",2D)="bump"{}
		_DepthTex("DepthTex",2D)="black"{}
		_Gloss("Gloss",Range(8,256))=20
		_HeightScale("HightScale",Range(-1.0,1.0))=0.1
		_MinLayerNum("MinlayerNum",Range(0,100))=30
		_MaxLayerNum("MaxLayerNum",Range(0,200))=50
	}
	SubShader{
		Tags{"RenderType"="Opaque"}
		Pass{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#define PI 3.14159265359

			fixed4 _MainColor;
			fixed4 _SpecularColor;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpTex;
			sampler2D _DepthTex;
			float _Gloss;
			float _HeightScale;
			float _MinLayerNum;
			float _MaxLayerNum;

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

			//通过步进方式找到 视角方向 与纹理交点 的实际高度值
			float2 ReliefMappingUV(float2 uv,float3 tangent_viewDir){
				//根据 切线空间视角方向在垂直于纹理表面的分量，确定步进的层数，越接近垂直，层数越多，步进距离越小
				float layerNum=lerp(_MinLayerNum,_MaxLayerNum,abs(dot(float3(0,0,1),tangent_viewDir)));
				float layerDepth=1.0/layerNum;
				float currentLayerDepth=0.0;
				float2 deltaUV=tangent_viewDir.xy/tangent_viewDir.z*_HeightScale/layerNum;

				float2 currentTexCoords=uv;
				float currentDepthMapValue=tex2D(_DepthTex,currentTexCoords).r;
			
				while(currentLayerDepth<currentDepthMapValue){
					currentTexCoords-=deltaUV;
					//在循环内需要加上unroll来限制循环次数或者改用tex2Dlod,直接使用tex2D采样会出现报错
					currentDepthMapValue=tex2Dlod(_DepthTex,float4(currentTexCoords,0,0)).r;
					currentLayerDepth+=layerDepth;
				}

				//进行二分法查找
				float2 halfDeltaUV=deltaUV/2.0;
				float halfLayerDepth=layerDepth/2.0;

				currentTexCoords+=halfDeltaUV;
				currentLayerDepth+=halfLayerDepth;

				int searchesNum=5;
				for(int i=0;i<searchesNum;i++){
					halfDeltaUV=halfDeltaUV/2.0;
					halfLayerDepth=halfLayerDepth/2.0;

					currentDepthMapValue=tex2Dlod(_DepthTex,float4(currentTexCoords,0,0)).r;
					if(currentLayerDepth<currentDepthMapValue){
						currentTexCoords-=halfDeltaUV;
						currentLayerDepth+=halfLayerDepth;
					}
					else{
						currentTexCoords+=halfDeltaUV;
						currentLayerDepth-=halfLayerDepth;
					}
				}

				return currentTexCoords;
			}

			v2f vert(a2v v){
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
				
				TANGENT_SPACE_ROTATION;
				o.lightDir=normalize(mul(rotation,ObjSpaceLightDir(v.vertex).xyz));
				o.viewDir=normalize(mul(rotation,ObjSpaceViewDir(v.vertex).xyz));
				
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				float3 tangent_lightDir=normalize(i.lightDir);
				float3 tangent_viewDir=normalize(i.viewDir); 
				
				float2 uv=ReliefMappingUV(i.uv,tangent_viewDir);
				//去掉边缘越界造成的纹理采样异常
				if(uv.x>1.0||uv.y>1.0||uv.x<0.0||uv.y<0.0)
					discard;

				float3 albedo=_MainColor.rgb*tex2D(_MainTex,uv).rgb;
				float3 ambient=UNITY_LIGHTMODEL_AMBIENT.rgb*albedo;

				float3 tangent_normal=normalize(UnpackNormal(tex2D(_BumpTex,uv)));
				
				//改进版 BRDF
				float3 diffuse=_LightColor0.rgb*albedo*max(0,saturate(dot(tangent_normal,tangent_lightDir)))/PI;
				float3 halfDir=normalize(tangent_viewDir+tangent_lightDir);
				float3 specular=_LightColor0.rgb*_SpecularColor.rgb*pow(saturate(dot(halfDir,tangent_normal)),_Gloss)*(8+_Gloss)/(8*PI);

				return fixed4(ambient+diffuse+specular,1.0);
			}

			ENDCG

		}
	}
}
