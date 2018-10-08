﻿Shader "Other/ForceField" {
	Properties {
		_MainColor ("Color" , Color) = (1,1,1,1)
		_HighlightColor("HighlightColor" ,Color) = (0,0,1,1)
		_EdgePow("Threshold" , Range(1 , 10)) = 1.0
		_RimNum("Rim" , Range(0 , 5)) = 1
		_MainTex("Main Tex" , 2D) = "white"{}
		_MaskTex("Mask Tex" ,  2D) = "white" {}
		_GridSize("GridSize",Float)=30
		_FlowSpeed("Speed" ,Range(1 , 3)) = 2
		_AlphaZone("AlphaZone",Range(0,1))=0.5
	}

	SubShader {

	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}
	
	Pass{
		Tags { "LightMode"="ForwardBase" }	
		
		Blend SrcAlpha OneMinusSrcAlpha
		ZWrite Off
		Cull Off
	
		CGPROGRAM

		#include "UnityCG.cginc"
		#include "Assets/Shaders/ShaderLibs/FBM.cginc"

		#pragma vertex vert
		#pragma fragment frag

		#define UNITY_PASS_FORWARDBASE
        #pragma multi_compile_fwdbase

		float4 _MainColor;
		float4 _HighlightColor;
		//获取深度纹理
		sampler2D _CameraDepthTexture;
		float _EdgePow;
		sampler2D _MainTex;
		float4 _MainTex_ST;
		sampler2D _MaskTex;
		float _FlowSpeed;
		float _RimNum;
		float _GridSize;
		float _AlphaZone;


		struct a2v{
			float4 vertex:POSITION;
			float3 normal:NORMAL;
			float2 tex:TEXCOORD0;
		};

		struct v2f{
			float4 pos:POSITION;
			float4 scrPos:TEXCOORD0;
			half3 worldNormal:TEXCOORD1;
			half3 worldViewDir:TEXCOORD2;
			float2 uv:TEXCOORD3;
		};

		float _Noise(in float2 x){return VNoise(x*0.75);}

		float2 Gradn(float2 p){
				float ep=0.09;
				float gradx=_Noise(float2(p.x+ep,p.y))-_Noise(float2(p.x-ep,p.y));
				float grady=_Noise(float2(p.x,p.y+ep))-_Noise(float2(p.x,p.y-ep));
				return float2(gradx,grady);
			}

		float FlowFBM(in float2 p){
				float z=2.;
				float rz=0.;
				float2 bp=p;
				//FBM 8层分形叠加
				for(float i=1.;i<9.;i++){
					//不同的层添加不同的速度 进行不同程度细节分形叠加
					p+=_Time.x*0.006;
					bp+=_Time.x*0.0006;
					//获取梯度,得到当前点的变化趋势(需在叠加前进行计算)
					float2 gr=Gradn(i*p*1.54+_Time.y*0.14*_FlowSpeed)*4.;
					p+=gr*.5;
					//FBM计算
					rz+=(sin(_Noise(p)*7.)*0.5+0.5)/z;
					//插值调整每层之间的效果
					p=lerp(bp,p,0.7);
					//FBM系数变化
					z*=1.4;
					p*=2.;
					bp*=1.9;
				}
				return rz;
			}


		v2f vert (a2v v )
		{
			v2f o;
			o.pos = UnityObjectToClipPos ( v.vertex );
			//ComputeScreenPos函数，得到归一化前的视口坐标xy，z分量为裁剪空间的z值，范围[-Near,Far] 
			o.scrPos = ComputeScreenPos(o.pos);

			float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; 
		
			o.worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
			o.worldNormal = UnityObjectToWorldNormal(v.normal); 

			o.uv = TRANSFORM_TEX(v.tex , _MainTex);
			//COMPUTE_EYEDEPTH函数，将z分量范围[-Near,Far]转换为[Near,Far]
			COMPUTE_EYEDEPTH(o.scrPos.z);
			return o;
		}
	
		fixed4 frag ( v2f i ) : SV_TARGET
		{
			//纹理和Mask部分，主要作用是实现基本纹理和噪声变化遮罩
			fixed mainTex = 1 - tex2D(_MainTex , i.uv).a;
			//fixed mask = tex2D(_MaskTex , i.uv + float2(0,(_Time.y)*_FlowSpeed)).r;
			float mask=FlowFBM(i.uv*_GridSize);
			fixed4 finalColor = lerp(_MainColor , _HighlightColor , mainTex);
			finalColor=lerp(fixed4(0,0,0,0),finalColor,mask);
			finalColor.a*=max(0,mask-cos(_AlphaZone*_Time.y))*0.4;
		
			//获取深度纹理,通过LinearEyeDepth函数将采样的深度纹理值转换为对应的深度范围[Near~Far]
			float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)));
			float partZ = i.scrPos.z;

			//diff为比较两个深度值，rim在能量盾自身边缘位置加上一层_HighlightColor的颜色
			float diff =pow((1-saturate(sceneZ-i.scrPos.z))/1.03,_EdgePow);
			half rim = pow(1 - abs(dot(normalize(i.worldNormal),normalize(i.worldViewDir))) , _RimNum);

			//最后通过插值混合颜色
			finalColor = lerp(finalColor, _HighlightColor, diff);
			finalColor = lerp(finalColor, _HighlightColor, rim);
			return finalColor;
		}

		ENDCG
		}
	}
}