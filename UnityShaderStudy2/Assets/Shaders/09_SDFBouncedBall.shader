Shader "ZB/09_SDFBouncedBall"
{
	Properties{
		_MainTex("Base RGB",2D)="white"{}
	}
	SubShader{
		pass{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment frag

			
			#define DEFAULT_RENDER
			#define DEFAULT_MAT_COL
			#define DEFAULT_PROCESS_FRAG
			#include "ShaderLibs/FrameWork3D_DefaultRender.cginc"

			float SdBounceBalls(float3 pos){
                float SIZE = 2;
                float2 gridSize = float2(SIZE,SIZE);
				//根据xz平面坐标位置随机相位
                float rv = Hash21( floor((pos.xz) / gridSize));
				//重复操作
                pos.xz = OpRep(pos.xz,gridSize);
                float bollSize = 0.2;
                float bounceH = .5;
                return SdSphere(pos- float3(0.,(bollSize+bounceH+sin(_Time.y*3.14 + rv*6.24)*bounceH),0.),bollSize);
            }

            float2 Map( in float3 pos )
            {
                float2 res = float2( SdPlane(pos), 1.0 )  ;
                res = OpU( res, float2( SdBounceBalls( pos),1.0) );
                return res;
            }
			
			ENDCG
		}
	}
	FallBack Off
}
