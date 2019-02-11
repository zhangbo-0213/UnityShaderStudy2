Shader "ZB/10_SDFScene"
{
	PrOperties
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

			#define DEFAULT_RENDER
			#define DEFAULT_MAT_COL
			#define DEFAULT_PROCESS_FRAG
			#include "ShaderLibs/FrameWork3D_DefaultRender.cginc"

			float3 SelfRotXZ(float3 pos,float speedSize,float phase=0.0){
				return float3(
					mul(Rot2DRad(_Time.y*speedSize+phase),pos.xz).x,
					pos.y,
					mul(Rot2DRad(_Time.y*speedSize+phase),pos.xz).y);
			}

			float3 SelfRotYZ(float3 pos,float speedSize,float phase=0.0){
				return float3(
				    pos.x,
					mul(Rot2DRad(_Time.y*speedSize+phase),pos.yz).x,
					mul(Rot2DRad(_Time.y*speedSize+phase),pos.yz).y);
			}

			float2 Map( in float3 pos )
			{
				float2 res = OpU( float2( SdPlane(pos), 1.0 ),float2( SdSphere(SelfRotXZ((pos-float3(0.0,0.30, 0.0)),1.0), 0.25 ), 46.9 ) );
				res = OpU( res, float2( SdBox(SelfRotXZ((pos-float3( 1.0,0.30, 0.0)),1.0), float3(0.25,0.25,0.25) ), 3.0 ) );
				res = OpU( res, float2( SdRoundBox(SelfRotXZ((pos-float3( 1.0,0.30, 1.0)),1.0,0.5), float3(0.15,0.15,0.15), 0.1 ), 41.0 ) );
				res = OpU( res, float2( SdTorus(SelfRotYZ((pos-float3( 0.0,0.25, 1.0)),1.0), float2(0.20,0.05) ), 25.0 ) );
				res = OpU( res, float2( SdCapsule(SelfRotXZ((pos-(float3(-1.3,0.10,-0.1)+float3(-0.8,0.50,0.2))/2.0),1.0),float3(-1.3,0.10,-0.1), float3(-0.8,0.50,0.2), 0.1  ), 31.9 ) );
				res = OpU( res, float2( SdTriPrism(SelfRotXZ((pos-float3(-1.0,0.30,-1.0)),1.0), float2(0.25,0.05) ),43.5 ) );
				res = OpU( res, float2( SdCylinder(SelfRotYZ((pos-float3( 1.0,0.30,-1.0)),1.0), float2(0.1,0.2) ), 8.0 ) );
				res = OpU( res, float2( SdCone(SelfRotXZ((pos-float3( 0.0,0.50,-1.0)),1.0), float3(0.8,0.6,0.3) ), 55.0 ) );
				res = OpU( res, float2( SdTorus82(SelfRotYZ((pos-float3( 0.0,0.25,2.0)),-1.0,-0.3), float2(0.20,0.05) ),50.0 ) );
				res = OpU( res, float2( SdTorus88(SelfRotYZ((pos-float3( -1.0,0.25,2.0)),1.0,0.2), float2(0.20,0.05) ),43.0 ) );
				res = OpU( res, float2( SdCylinder6(SelfRotXZ((pos-float3( 1.0,0.30,2.0)),1.0), float2(0.1,0.2) ), 12.0 ) );
				res = OpU( res, float2( SdHexPrism(SelfRotXZ((pos-float3( -1.0,0.30,1.0)),1.0), float2(0.25,0.05) ),17.0 ) );
				res = OpU( res, float2( SdPryamid4(SelfRotXZ((pos-float3( -1.0,0.50,-2.0)),1.0), float3(0.8,0.6,0.25) ),37.0 ) );
				res = OpU( res, float2( OpS(SdRoundBox(SelfRotXZ((pos-float3( -2.0,0.30,1.0)),1.0), float3(0.15,0.15,0.15),0.05), SdSphere(pos-float3(-2.0,0.3, 1.0), 0.25-0.02*sin(_Time.y))), 13.0 ) );
				res = OpU( res, float2( OpS( SdTorus82(pos-float3(-2.0,0.2, 0.0), float2(0.20,0.1)),SdCylinder(OpRep( float3(atan2(abs(pos.x+2.0),abs(pos.z))/6.2831, pos.y, 0.02+0.5*length(pos-float3(-2.0,0.2, 0.0))), float3(0.05,1.0,0.05)), float2(0.02,0.6))), 51.0 ) );
				res = OpU( res, float2( 0.5*SdSphere(pos-float3(-2.0,0.25,-1.0), 0.2) + 0.03*sin(50.0*pos.x+_Time.y)*sin(50.0*pos.y+_Time.y)*sin(50.0*pos.z+_Time.y), 65.0 ) );
				res = OpU( res, float2( 0.5*SdTorus(OpTwist(SelfRotXZ((pos-float3( -2.0,0.30,2.0)),1.0)),float2(0.20+0.05*sin(_Time.y),0.05)), 46.7 ) );
				res = OpU( res, float2( SdConeSection(pos-float3( 0.0,0.35,-2.0), 0.15, 0.2, 0.1 ), 13.67 ) );
				res = OpU( res, float2( SdEllipsoid(SelfRotXZ((pos-float3( 1.0,0.35,-2.0)),1.0), float3(0.15, 0.2, 0.1) ), 43.17 ) );
                res = OpU( res, float2( OpSmoothUnion(SdBox(SelfRotXZ((pos-float3( -2.0,0.30,-2.0)),0.5), float3(0.25,0.25,0.25) ), SdSphere(pos-float3( -2.0,0.6+0.35*sin(_Time.y),-2.0), 0.15 ),0.5),42.0));
				return res;
			}
		ENDCG
		}
	}
}
