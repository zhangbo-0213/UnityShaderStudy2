Shader "Other/Hologram"
{
    Properties{
		_MainTex("MainTex",2D)="white"{}
		_MainColor("MainColor",Color)=(0,1,0,1)
		_Bias("Bias",Range(-2,2))=0
		_ScanningFrequency("ScanningFrequency",Float)=100
		_ScanningSpeed("ScanningSpeed",Float)=100
	}
	SubShader{
		Pass{
			Tags{"Queue"="Transparent" "RenterType"="Transparent"}
			ZWrite off
			Blend SrcAlpha OneMinusSrcAlpha
			//关闭背后剔除
			Cull off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _MainColor;
			fixed _Bias;
			float _ScanningFrequency;
			float _ScanningSpeed;

			struct a2v{
				float4 vertex:POSITION;
				float2 texcoord:TEXCOORD0;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
				float4 worldPos:TEXCOORD1;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.uv=TRANSFORM_TEX(v.texcoord,_MainTex);
				o.worldPos=mul(unity_ObjectToWorld,v.vertex);

				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				fixed4 col=tex2D(_MainTex,i.uv);
				//根据物体在世界空间的坐标位置进行余弦变换(-1~1),可以裁掉一半
				col=_MainColor*max(0,cos(i.worldPos.y*_ScanningFrequency+_Time.x*_ScanningSpeed)+_Bias);
				col*=1-max(0,cos(i.worldPos.z*_ScanningFrequency+_Time.x*_ScanningSpeed)+0.9);
				col*=1-max(0,cos(i.worldPos.x*_ScanningFrequency+_Time.x*_ScanningSpeed)+0.9);
				
				return saturate(col);
			}
			ENDCG
		}
	}
}
