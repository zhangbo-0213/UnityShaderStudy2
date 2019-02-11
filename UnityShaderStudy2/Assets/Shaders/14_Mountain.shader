﻿Shader "ZB/14_Mountain"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_LoopNum("_LoopNum",Vector)=(314.,1,1,1)
		_MaxTerrainH("_MaxTerrainH",float)=500.
		_ShadowScale("_ShadowScale",Range(0,0.2))=0.08
	}
	SubShader
	{
		Pass{
			ZTest Always Cull off ZWrite off

			CGPROGRAM
			#define USING_VALUE_NOISE
			#pragma vertex vert 
			#pragma fragment frag
			#include "ShaderLibs/FrameWork3D_Mountain.cginc"

			float _MaxTerrainH;
			float _ShadowScale;

			//地形噪声FBM分形处理
			#define TerrainMap(pos,NUM)\
				float2 p=pos.xz*0.9/_MaxTerrainH;\
				float a=0.0;\
				float b=0.491;\
				for(int i=0;i<NUM;i++){\
					float n=VNoise(p);\
					a+=b*n;\
					b*=0.49;\
					p*=2.01;\
				}\
				return float2(pos.y-_MaxTerrainH*a,1.0);


			float2 TerrainMap_L(float3 pos){
				TerrainMap(pos,5.);
			}

			float2 TerrainMap_M(float3 pos){
				TerrainMap(pos,9.);
			}

			float2 TerrainMap_H(float3 pos){
				TerrainMap(pos,15.);
			}

			float3 MountainRender(float3 pos,float3 ro,float3 rd,float rz,float3 nor,float3 lightDir){
				float3 col=float3(0.0,0.0,0.0);
				//base color
				col=float3(0.1,0.09,0.08);

				//base Lighting
				float amb=clamp(0.5+0.5*nor.y,0.0,1.0);
				float dif=clamp(dot(lightDir,nor),0.0,1.0);
				float bac=clamp(0.2+0.8*dot(normalize(float3(-lightDir.x,0.0,lightDir.z)),nor),0.0,1.0);

				//shadow
				float sh=SoftShadow(pos+lightDir*_MaxTerrainH*_ShadowScale,lightDir,_MaxTerrainH*1.2);

				//brdf
				float3 lin=float3(0.0,0.0,0.0);
				lin+=amb*float3(0.40,0.60,1.00)*1.2;
				lin+=dif*float3(7.00,5.00,3.00)*float3(sh, sh*sh*0.5+0.5*sh, sh*sh*0.8+0.2*sh);
				lin+=bac*float3(0.40,0.50,0.60);
				col*=lin;
				//fog
				//步进距离累加值的指数雾效
				float fo=1.0-exp(-pow(0.1*rz/_MaxTerrainH,1.5));
				//float fo=(rz/_MaxTerrainH)*0.2;
				float3 fco=0.65*float3(.4,.65,1.0);
				col=lerp(col,fco,fo);

				return col;
			}

			float4 ProcessRayMarch(float2 uv,float3 ro,float3 rd,inout float sceneDep,float4 sceneCol){
				float tmax=5000.0;
				float rz=RaycastTerrain(ro,rd).x;
				float3 pos=ro+rd*rz;
				float3 nor=NormalTerrain(pos,rz);
				
				float3 col=float3(0.0,0.0,0.0);
				if(rz>tmax){
					col=Sky(ro,rd,_LightDir);
				}
				else{
					col=MountainRender(pos,ro,rd,rz,nor,_LightDir);
				}
				col=pow(col,float3(0.4545,0.4545,0.4545));
				sceneCol.xyz=col;
				return sceneCol;
			}
			ENDCG
		}
	}
}
