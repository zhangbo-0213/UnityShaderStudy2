Shader "ZB/07_RayMarchingSimple"
{
	//光线追踪基本步骤：
	//获得相机位置ro
	//根据相机位置和朝向,计算当前像素所发出的射线ray的方向rd(ray dir)
	//求交ray和场景的碰撞点p(两种方式) 
		//3.1 直接算式求解(比如射线到一个简单的圆的交点) 
		//3.2 使用raymarching方式即一步步的递进ray,直到ray碰到场景，或达到ray的最大距离。
	//求得p处的法线和材质信息
	//根据4得到的信息求的p处的颜色
	//--------------------- 
	//作者：JiepengTan 
	//来源：CSDN 
	//原文：https://blog.csdn.net/tjw02241035621611/article/details/80057928 
	Properties{
		_MainTex("MainTex",2D)="white"{}
	}
	SubShader{
		Tags {"RenderType"="Opaque"}
		LOD 100
		Pass{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct a2v{
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(a2v a){
				v2f o;
				o.pos=UnityObjectToClipPos(a.vertex);
				o.uv=TRANSFORM_TEX(a.texcoord,_MainTex);
				return o;
			}

			#define SPHERE_ID (1.0)
			#define FLOOR_ID (2.0)
			#define lightDir (normalize(float3(5.0,3.0,-1.0)))

			float MapSphere(float3 pos){
				float radius=0.5;
				float3 centerPos=float3(0.,1.0+sin(_Time.y*1.)*0.5,0.);
				//距离球体边缘的距离
				return length(pos-centerPos)-radius;
			}

			float MapFloor(float3 pos){
				float3 n=float3(0.,1.,0.);
				float d=0;
				//距离地面的高度
				return dot(pos,n)-d;
			}

			//计算最逼近的物体
			float2 Map(float3 pos){
				float dist2Sphere=MapSphere(pos);
				float dist2Floor=MapFloor(pos);
				if(dist2Sphere<dist2Floor)
					return float2(dist2Sphere,SPHERE_ID);
				else{
					return float2(dist2Floor,FLOOR_ID);
				}
			}

			//最多光线检测距离
			#define MARCH_NUM 256
			//检测光线步进后最先接触到的物体及距离  参数：ro_相机位置 rd_根据相机位置及朝向，计算当前像素所发出的射线ray的方向
			float2 RayCast(float3 ro,float3 rd){
				float tmin=0.1;
				float tmax=20.0;

				float t=tmin;
				float2 res=float2(0,-1.0);
				float precis=0.0005;
				for(int i=0;i<MARCH_NUM;i++){
					float3 pos=ro+rd*t;
					res=Map(pos);
					if(res.x<precis||t>tmax) break;
					t+=res.x*0.5;  //步进策略  取余量的1/2
				}
				if(t>tmax) return float2(t,-1.0);
				return float2(t,res.y);
			}
			//计算阴影从pos点朝着光源方向步进
			float SoftShadow(float3 ro,float3 rd){
				float res=1.0;
				float t=0.001;
				for(int i=0;i<80;i++){
					float3 p=ro+rd*t;
					float h=Map(p);
					
					res=min(res,16.0*h/t);
					t+=h;
					if(res<0.001||p.y>(2.0)) break;
				}
				return clamp(res,0.0,1.0);
			}

			float3 ShadingSphere(float3 n){
				float3 col=float3(1.,0.,0.);
				float diff=clamp(dot(n,lightDir),0.,1.);
				float bklig=clamp(dot(n,-lightDir),0.,1.)*0.05; //使背面受到光照影响，增加背光
				return (diff+bklig)*col;
			}

			float3 ShadingFloor(float3 n,float3 sd){
				float3 col=float3(0.,0.,1.);
				float diff=clamp(dot(n,lightDir),0.,1.);
				return diff*col*sd;
			}

			float3 ShadingBG(float3 rd){
				float val=pow(rd.y,2.0);
				float3 bCol=float3(0.,0.,0.);
				float3 uCol=float3(0.1,0.2,0.9);
				return lerp(bCol,uCol,val);
			}

			float3 Shading(float3 pos,float3 n,float matID){
				float sd=SoftShadow(pos,lightDir);
				if(matID>(FLOOR_ID-0.5)){
					return ShadingFloor(n,sd);
				}
				else{
					return ShadingSphere(n);
				}
			}

			//求碰撞点处的近似法线
			float3 Normal(float3 pos,float t){
				float val=0.0001*t*t;
				float3 eps=float3(val,0.,0.);
				float3 nor=float3(
					Map(pos+eps.xyy).x-Map(pos-eps.xyy).x,
					Map(pos+eps.yxy).x-Map(pos-eps.yxy).x,
					Map(pos+eps.yyx).x-Map(pos-eps.yyx).x
				);
				return normalize(nor);
			}

			void SetCamera(float2 uv,out float3 ro,out float3 rd){
				//步骤1 获取相机位置
				ro=float3(0.,2.,-5.0);
				float3 ta=float3(0.,0.5,0.);//获取目标位置
				float3 forward=normalize(ta-ro);//计算forward方向
				float3 left=normalize(cross(float3(0.,1.0,0.),forward));//计算left方向
				float3 up=normalize(cross(forward,left));//计算up方向
				const float zoom=1;
				//步骤2 获得射线朝向 空间变换(平面UV转化到相机坐标中)
				rd=normalize(uv.x*left+uv.y*up+zoom*forward);
			}

			fixed4 frag (v2f i):SV_Target
			{
				float2 uv=(i.uv-0.5)*float2(_ScreenParams.x/_ScreenParams.y,1.0);
				float3 ro,rd;
				//步骤1 步骤2 
				SetCamera(uv,ro,rd);
				//步骤3 求ray和场景的碰撞点p
				float2 ret=RayCast(ro,rd);
				float3 pos=ro+ret.x*rd;
				//步骤4 求碰撞点的法线信息
				float3 nor=Normal(pos,ret.x);

				//步骤5 使用步骤4获得的信息计算当前像素的颜色值
				float3 col=Shading(pos,nor,ret.y);
				if(ret.y<-0.5){
					col=ShadingBG(rd);
				}
				return fixed4(col,1.0);
			}
			ENDCG
		}
	}
}
