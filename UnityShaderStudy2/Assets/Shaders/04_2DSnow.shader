Shader "ZB/04_2DSnow" {
	Properties {
		_MainTex("MainTex",2D)="white"{}
		SIZE_RATE("SIZE_RATE",float)=0.1
		XSPEED("XSPEED",float)=0.2
		YSPEED("YSPEED",float)=0.5
		LAYERS("LAYERS",float)=10
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
			#include "ShaderLibs/FrameWork2D.cginc"

			float SIZE_RATE;
			float XSPEED;
			float YSPEED;
			float LAYERS;

			float3 SnowSingleLayer(float2 uv,float layer){
				//根据层数进行网格划分，层越大，网格越密，雪花越小，同样的下落速度耗时越长
				//形成近处雪花下落快，远处雪花下落慢的效果
				uv = uv * (2.0+layer);//透视视野变大效果
			    float xOffset = uv.y * (((Hash11(layer)*2-1.)*0.5+1.)*XSPEED);//增加x轴移动
			    float yOffset = (YSPEED*_Time.y);//y轴下落过程
				uv += fixed2(xOffset,yOffset);
				float2 rgrid = Hash22(floor(uv)+(31.1759*layer));
				
				//UV原点向网格中央推移，使雪花原点能够完全显示，避免明显裁剪
				uv = frac(uv);
				uv -= (rgrid*2-1.0) * 0.35;
				uv -=0.5;
				//雪花随机裁剪大小
				float r = length(uv);
				float circleSize = 0.05*(1.0+0.3*sin(_Time.y*SIZE_RATE));
				float val = smoothstep(circleSize,-circleSize,r);
				float3 col = float3(val,val,val)* rgrid.x ;
				return col;
			}
			float3 Snow(float2 uv){
				float3 acc = float3(0,0,0);
				for (fixed i=0.;i<LAYERS;i++) {
					acc += SnowSingleLayer(uv,i); 
				}
				return acc;
			}
			float3 ProcessFrag(float2 uv)  {
				uv *= float2(_ScreenParams.x/_ScreenParams.y,1.0);
				return Snow(uv);
            }
			ENDCG
		}
	}
}

