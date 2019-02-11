Shader "ZB/08_RayMarchMergeRaster"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#include "ShaderLibs/FrameWork3D.cginc"

			#define SPHERE_ID (1.0)
			#define FLOOR_ID (2.0)
			#define lightDir (normalize(float3(5,3.0,-1.0)))

			float MapSphere(float3 pos){
				float radius=0.5;
				float3 centerPos=float3(0.,1.0+sin(_Time.y*1.0)*0.5,0.);
				return length(pos-centerPos)-radius;
			}
			float MapFloor(float3 pos){
				float3 n=float3(0.,1.,0.);
				float  d=0;
				return dot(pos,n)-d;
			}
			float2 Map(float3 pos){
				float distSphere=MapSphere(pos);
				float distFloor=MapFloor(pos);
				if(distSphere<distFloor){
					return float2(distSphere,SPHERE_ID);
				}else{
					return float2(distFloor,FLOOR_ID);
				}
			}

			#define MARCH_NUM 256 //最多光线检测次数
			float2 RayCast(float3 ro,float3 rd){
				float tmin=0.1;
				float tmax=20.0;

				float t=tmin;
				float2 res=float2(0,-1.0);
				for(int i=0;i<MARCH_NUM;i++){
					float precis=0.0005;
					float3 pos=ro+t*rd;
					res=Map(pos);
					if(res.x<precis||t>tmax) break;
					t+=res.x*0.5;
				}
				if(t>tmax) return float2(t,-1.0);
				return float2(t,res.y);
			}

			float SoftShadow(float3 ro,float3 rd){
				float res=1.0;
				float t=0.001;
				for(int i=0;i<80;i++){
					float3 p=ro+t*rd;
					float h=Map(p);
					res=min(res,16.0*h/t);
					t+=h;
					if(res<0.001||p.y>(200.0)) break;
				}
				return clamp(res,0.0,1.0);
			}

			float3 ShadingShpere(float3 n){
				float3 col=n;//将法线向量映射为颜色
				float  diff=clamp(dot(n,lightDir),0.,1.);
				float  bklig=clamp(dot(n,-lightDir),0.,1.)*0.05;//加背光
				return col*(diff+bklig);
			}

			float3 ShadingFloor(float3 n,float sd,float3 pos){
				//CheckersGradBox 棋盘纹理绘制
				float f=CheckersGradBox(2.0*pos.xz);
				float3 col=float3(0.2,0.3,0.7)*f;
				float  diff=clamp(dot(n,lightDir),0.,1.);
				return col*diff*sd;
			}

			float3 ShadingBG(float3 rd){
				float val=pow(rd.y,2.0);
				float3 bCol=float3(0,0,0);
				float3 uCol=float3(0.3,0.5,0.8);
				return lerp(bCol,uCol,val);
			}

			float3 Shading(float3 pos,float3 n,float matID){
				float sd=SoftShadow(pos,lightDir);
				if(matID>=(FLOOR_ID-0.5)){
					return ShadingFloor(n,sd,pos);
				}
				else{
					return ShadingShpere(n);
				}
			}

			float3 Normal(float3 pos,float t){
				float val=0.0001*t*t;
				float3 eps=float3(val,0.0,0.0);
				float3 nor=float3(
					Map(pos+eps.xyy).x-Map(pos-eps.xyy).x,
					Map(pos+eps.yxy).x-Map(pos-eps.yxy).x,
					Map(pos+eps.yyx).x-Map(pos-eps.yyx).x);
				return normalize(nor);
			}

			float4 ProcessRayMarch(float2 uv,float3 ro,float3 rd,inout float sceneDep,float4 sceneCol){
				float2 ret=RayCast(ro,rd);
				float3 pos=ro+rd*ret.x;
				float  matID=ret.y;
				float  rz=ret.x;
				//计算碰撞点法线信息
				float3 nor=Normal(pos,ret.x);
				//使用碰撞点的信息计算当前像素颜色值
				float3 col=Shading(pos,nor,matID);
				if(ret.y<-0.5){
					col=ShadingBG(rd);
				}
				//检测Unity中场景的z值时候小于raymarch场景中的t值，类似ZTest
				if(sceneDep<rz){
					col=sceneCol;
					rz=sceneDep;
				}
				return float4(col,1.0);
			}
			ENDCG
		}
	}
	FallBack off
}
