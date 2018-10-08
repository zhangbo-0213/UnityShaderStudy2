Shader "Other/Ring"
{
    Properties
    {
        _RingColor("RingColor",Color)=(1,0,0,1)
		_ColorIndentity("ColorIndentity",Range(0.0,1.0))=0.5
		_RangeFactor("RangeFactor",Range(0.5,2.0))=1.0
    }
    SubShader
    {
		Pass{
			Tags{"Queue"="Opaque" "RenderType"="Opaque"}
			ZWrite on
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct a2v{
				float4 vertex:POSITION;
			};
			struct v2f{
				float4 pos:SV_POSITION;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				return o;
			}
			fixed4 frag(v2f i):SV_Target{
				fixed4 color=fixed4(1,1,1,1);
				return color;
			}

			ENDCG
		}
		Pass{
			Tags{"Queue"="Transparent" "RenderType"="Opaque"}

			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite off

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			fixed4 _RingColor;
			fixed   _ColorIndentity;
			fixed _RangeFactor;

			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
			};
			
			struct v2f{
				float4 pos:SV_POSITION;
				fixed4 color:TEXCOORD0;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				float3 viewDir=normalize(ObjSpaceViewDir(v.vertex));
				//计算模型空间下，顶点的法线与视角方向的点积，越靠近边缘点积结果越小，根据该结果进行着色
				float val=1-saturate(dot(viewDir,v.normal));
				o.color=_RingColor*(1+_ColorIndentity)*val;
				o.color.a=pow(o.color.a,_RangeFactor);
				return o;
			}

			fixed4 frag(v2f i):SV_Target{
				return i.color;
			}
			ENDCG
		}
    }
}