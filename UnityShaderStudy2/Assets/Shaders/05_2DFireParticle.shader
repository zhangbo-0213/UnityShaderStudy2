Shader "ZB/05_2DFireParticle" {
	Properties {
		_MainTex("MainTex",2D)="white"{}
		_Color("Color",color)=(1.0,0.3,0.0,1.0)
		_GridSize("SparkGridSize",float )=30
		_RotSpeed("RotSpeed",float)=0.5
		_YSpeed("YSpeed",float)=0.5
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

			fixed4 _Color;
			float _GridSize;
			float _RotSpeed;
			float _YSpeed;

			float3 ProcessFrag(float2 uv){
				float3 acc=float3(0.0,0.0,0.0);

				float RotDeg=3.*_RotSpeed*_Time.y;
				float YOffset=4.*_YSpeed*_Time.y;

				float2 coord=uv*_GridSize-float2(0,YOffset); //整体沿着Y轴上移
				if(abs(fmod(coord.y,2.0))<1.0)  //格子隔行交错
					coord.x+=0.5;

				float2 gridIndex=float2(floor(coord));
				float rnd=Hash21(gridIndex); //根据所处的网格序列获取随机值
				float tempY=gridIndex.y+YOffset; //获取随时间变化前的Y值，根据Y值划分大致的粒子生命周期消失位置
				float life=min(10.0*(1.0-min((tempY/(24.-20.*rnd)),1.0)),1.0); //根据tempY随机生命值

				if(life>0.0){
					float size=0.08*rnd;
					float deg=999.0*rnd*2.0*PI+RotDeg*(0.5+0.5*rnd);//旋转随机
					float radius=0.5-size*0.2;//size越大，偏移半径越小，即粒子越小飘散效果越明显
					float2 cirOffset=radius*float2(sin(deg),cos(deg));
					float2 part=frac(coord-cirOffset)-0.5;//网格自身旋转

					float len=length(part);
					float sparkGray=max(0.0,1.0-len/size); //画圆裁剪
					//添加闪烁
					float sinval=sin(PI*1.*(0.3+0.7*rnd)*_Time.y+rnd*10.);
					float period=clamp(pow(pow(sinval,5.),5.),0.0,1.0); //使用 pow 控制范围强度
					float blink=(0.8+0.8*abs(period));

					acc+=life*sparkGray*_Color*blink;
				}
				return acc;
			}
			ENDCG
		}
	}
}

