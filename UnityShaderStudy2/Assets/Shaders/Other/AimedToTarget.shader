Shader "Other/AimedToTarget"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
		_ArrowTex ("ArrowTexture", 2D) = "white" {}
		_TargetTex ("TargetTexture", 2D) = "white" {}
		_TargetPosition("TargetPosition",Vector) = (0,0,0,0)
		_Scale("Scale",float) = 1000
	}
	SubShader
	{
		Tags { "RenderType"="TransparentCutout"  "Queue"="Overlay"}
		LOD 100
		Cull Off
		ZWrite Off
		ZTest Off
		Blend SrcAlpha OneMinusSrcAlpha
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			
			#include "UnityCG.cginc"

			uniform fixed4 _Color;
			uniform sampler2D _ArrowTex;
			uniform sampler2D _TargetTex;
			uniform float4 _TargetPosition;
			uniform float _Scale;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed TargetEdge :  TEXCOORD1;
			};
			
			
			
			v2f vert (appdata v)
			{
				v2f o;
				o.uv = v.uv;
				o.TargetEdge = 0;

				_TargetPosition = UnityWorldToClipPos(_TargetPosition);
				float w = 1/_TargetPosition.w;
				//_TargetPosition 方向矢量(由观察空间转换到裁剪空间，以相机位置为坐标原点)
				_TargetPosition = float4(_TargetPosition.x*w,_TargetPosition.y*w,_TargetPosition.z*w,0);
				
				//_TargetPosition 方向矢量与摄像机方向同反向时的处理
				fixed i = step(0,_TargetPosition.z);
				_TargetPosition.x*=2*i-1;
				_TargetPosition.y*=2*i-1;

				float l=max(abs(_TargetPosition.x),abs(_TargetPosition.y));
				//超出视野范围,更换箭头纹理，并计算旋转角度
				if( l>=1)
				{
					o.TargetEdge = 1;
					//限定坐标范围
					_TargetPosition.x*=0.9/l;
					_TargetPosition.y*=0.9/l;
				   //箭头角度旋转计算
					half angle = atan2(_TargetPosition.y,_TargetPosition.x);
					angle -= UNITY_HALF_PI;
					float4 temp=v.vertex;
					v.vertex.x = cos(angle)*temp.x - sin(angle)*temp.y;
					v.vertex.y = sin(angle)*temp.x + cos(angle)*temp.y;
				}

				_TargetPosition.z=1;
				
				//乘屏幕分辨率系数
				v.vertex.x *= _Scale/_ScreenParams.x;
				v.vertex.y *= _Scale/_ScreenParams.y;

				o.vertex =_TargetPosition+v.vertex;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;
				if(i.TargetEdge==1)
					col=tex2D(_ArrowTex, i.uv);
				else
					col=tex2D(_TargetTex, i.uv);
				col*=_Color;
				return col;
			}
			ENDCG
		}
	}
}
