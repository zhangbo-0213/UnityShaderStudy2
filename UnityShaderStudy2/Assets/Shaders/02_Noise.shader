Shader "ZB/02_Noise" {
	Properties {
		_MainTex("MainTex",2D)="white"{}
		_Color("Color",color)=(1,1,1,1)
	}
	SubShader {
		Tags{"RenderType"="Transparent" "Queue"="Transparent"}
		
		Pass{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define USING_PERLIN_NOISE
			#include "ShaderLibs/FrameWork2D.cginc"

			float2 Gradn(float2 p){
				float ep=0.09;
				float gradx=Noise(float2(p.x+ep,p.y))-Noise(float2(p.x-ep,p.y));
				float grady=Noise(float2(p.x,p.y+ep))-Noise(float2(p.x,p.y-ep));
				return float2(gradx,grady);
			}

			#define DrawInGrid(uv,DRAW_FUNC)\
			{\
				float2 pfloor=floor(uv);\
				if(length(pfloor-float2(j,i))<0.1){\
					float2 _uv=uv;\
					_uv*=4.;\
					col=(DRAW_FUNC(_uv)+1.0)*0.5;\
				}\
				num=num+1.000;\
				i=floor(num/gridSize);\
				j=fmod(num,gridSize);\
			}\

			fixed4 _Color;

			

			//绘制格子线
			float3 DrawGridLine(float2 uv){
				float2 _uv=frac(uv);
				float val=0.0;
				float eps=0.01;
				if(_uv.x<eps||_uv.y<eps){
					val=1.0;
				}
				return float3(val,val,val);
			}

			float3 ProcessFrag(float2 uv){
				float3 col = float3(0.0,0.0,0.0);
			    float num = 0.;
				float gridSize= 2.;
				float i =0.,j=0.;
				uv*=gridSize;
				
				
				DrawInGrid(uv,Noise_Self);
				DrawInGrid(uv,Noise_Sum);
				DrawInGrid(uv,Noise_Sum_Abs);
				DrawInGrid(uv,Noise_Sum_Abs_Sin);
				col*=_Color;
				col +=DrawGridLine(uv);
	
				return col;			
			}

			ENDCG
		}
	}
}

