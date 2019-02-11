Shader "ZB/13_Sky"
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
			
			#include "ShaderLibs/FrameWork3D.cginc"

			float3 SkyRender(float3 ro,float3 rd){
				fixed3 col=fixed3(0.0,0.0,0.0);
				float3 light1=normalize(float3(0.8,0.4,0.8));
				float sundot=clamp(dot(rd,light1),0.0,1.0);

				//基本天空颜色过渡
				//利用rd在高度方向上的分量值进行颜色混合插值
				col=float3(0.2,0.5,0.85)*1.1-rd.y*rd.y*0.5;
				col=lerp(col,0.85*float3(0.7,0.75,0.85),pow(1.0-max(rd.y,0.0),4.0));

				//太阳绘制
				//指定太阳光方向，利用pow约束增强rd与光照方向点积结果，
				//形成某一区域内的颜色值较强,绘制太阳效果
				col+=0.35*float3(1.0,0.2,0.1)*pow(sundot,5.0);
				col+=0.35*float3(1.0,0.3,0.2)*pow(sundot,64.0);
				col+=0.25*float3(1.0,0.8,0.6)*pow(sundot,512.0);

				//云
				col=Cloud(col,ro,rd,float3(1.0,0.9,0.9),1,1);
				//过滤地平线以下的部分
				col=lerp(col,0.68*float3(0.4,0.65,1.0),pow(1.0-max(rd.y,0.0),16.0));
				return col;
			}

			float4 ProcessRayMarch(float2 uv,float3 ro,float3 rd,inout float sceneDep,float4 sceneCol){
				sceneCol.xyz=SkyRender(ro,rd);
				return sceneCol;
			} 

			ENDCG
		}
	}
}
