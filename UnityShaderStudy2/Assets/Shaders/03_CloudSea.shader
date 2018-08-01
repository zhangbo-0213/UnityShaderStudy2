Shader "ZB/03_CloudSea" {
	Properties {
		_MainTex("MainTex",2D)="white"{}
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

			#define LAYER 22.0

			float Circle(fixed2 uv,fixed2 center,float size,float blur){
				uv=uv-center;
				uv/=size;
				float len=length(uv);
				return smoothstep(1.,1.-blur,len);
			}

			//海浪  层级越高，振幅越大，频率越低
			fixed Wave(float layer,fixed2 uv,fixed val){
				//振幅
				float amplitude=layer*layer*0.00004;
				//频率
				float frequency=val*200*uv.x/layer;
				//相位
				float phase=9.*layer+_Time.z/val;
				return amplitude*sin(frequency+phase);
			}

			//太阳波浪形圆环
			float AngleCircle(fixed2 uv,fixed2 center,float size,float blur){
				uv=uv-center;
				uv/=size;
				//极坐标转化，用于处理动态的旋转
				float deg=atan2(uv.y,uv.x)+_Time.y*-0.1;
				float len=length(uv);
				//绘制太阳外侧波浪形圆环
				float offs=(sin(deg*9)*3.+sin(11*deg+sin(_Time.y*6)*.5))*0.05;
				return smoothstep(1.+offs,1.+offs-blur,len);
			}

			//将圆进行偏移合成，组成云朵
			float DrawCloud(fixed2 uv,fixed2 center,float size){
				uv=uv-center;
				uv/=size;
				//单个云朵中心处最大圆
				float col=	Circle(uv,fixed2(0,0),0.2,0.05);
				//将圆不需要的一部分去除
				col*=smoothstep(-0.1,-0.1+0.01,uv.y);
				//偏移组合不同的圆，形成云朵外观
				 col += Circle(uv,fixed2(0.15,-0.05),0.1,0.05);
				 col += Circle(uv,fixed2(0.,-0.1),0.11,0.05);
				 col += Circle(uv,fixed2(-0.15,-0.1),0.1,0.05);
				 col += Circle(uv,fixed2(-0.3,-0.08),0.1,0.05);
				 col += Circle(uv,fixed2(-0.2,0.),0.15,0.05);
				 return col;
			}

			//绘制多个云朵
			float DrawClouds(fixed2 uv){
				uv.x+=0.03*_Time.y;
				//frac 的范围 在 0~1 为了使 -0.5~0 的部分显示出来，这里需要进行-0.5 映射
				uv.x=frac(uv.x+0.5)-0.5;
				float col = DrawCloud( uv,fixed2(-0.4,0.3),0.2);
				col += DrawCloud( uv,fixed2(-0.2,0.42),0.2);
				col += DrawCloud( uv,fixed2(0.0,0.4),0.2);
				col += DrawCloud( uv,fixed2(0.15,0.3),0.2);
				col += DrawCloud( uv,fixed2(0.45,0.45),0.2);
				return col;
			}

			float3 ProcessFrag(float2 uv){
				float3 col=float3(0.0,0.0,0.0);
				float num=0.;
				for(float i=1.;i<LAYER;i++)
				{
					//分形叠加
					float wave=2.*Wave(i,uv,1.)+Wave(i,uv,1.8)+.5*Wave(i,uv,3.);
					//控制海浪高度
					float layerVal=0.7-0.03*i+wave;
					if(uv.y>layerVal){
						break;
					}
					//记录所在层的 num
					num=i;	
				}
				//计算每一层的基本颜色
				col=num*fixed3(0,0.03,1);
				//每一层的颜色叠加
				col+=(LAYER-num)*fixed3(0.04,0.04,0.04);
				//如果在海平面以上
				if(num==0){
					//添加海平面以上的颜色渐变
					float ry=Remap(0.7,1.0,1.0,0.0,uv.y);
					col=lerp(fixed3(0.1,0.6,0.9),fixed3(0.1,0.7,0.9),ry);
					col+=pow(ry,10.)*fixed3(0.9,0.2,0.1)*0.2;
				}
				//调整UV为(-0.5,-0.5,0.5,0.5)方便绘图
				uv = uv - fixed2(0.5,0.5);
				//添加太阳
				fixed2 sunPos = fixed2(0.3,0.35);
				fixed sun = Circle(uv,sunPos,0.06,0.05);
				fixed sunCircle = AngleCircle(uv,sunPos,0.08,0.05);
				col = lerp( col ,fixed3(0.9,0.6,0.15),sunCircle);
				col = lerp( col ,fixed3(0.98,0.9,0.1),sun);
				//云绘制
				col+=DrawClouds(uv);

				return col;
			}
			ENDCG
		}
	}
}

