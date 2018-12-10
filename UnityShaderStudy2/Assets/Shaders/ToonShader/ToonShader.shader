Shader "Custom/ToonShader"
{
	Properties{
		_SpecularSize("SpecularSize",float)=1.0
		_SpecularStrength("SpecularStrength",float)=1.0
		_RotateAngle("RotateAngle",float)=1.0
		_EmissionMultiplier("EmissionMultiplier",float)=1.0
		_FresnelPower("FresnelPower",float)=1.0
		_AlbedoMap("AlbedoMap",2D)="white"{}
		_NormalMap("NormalMap",2D)="bump"{}
		_LineMap("LineMap",2D)="white"{}
		_EmissionMap("EmissionMap",2D)="white"{}

		_IsOutline("OutLine Trigger",float)=1.0
		_OutlineWidth("OutLine Width",float)=1.0
		_OutlineColor("Outline Color",color)=(0,0,0,1)

	}
	SubShader{
		CGINCLUDE
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "../ShaderLibs/Math.cginc"

			float _SpecularSize;
			float _SpecularStrength;
			float _RotateAngle;
			float _EmissionMultiplier;
			float _FresnelPower;
			sampler2D _AlbedoMap;
			float4 _AlbedoMap_ST;
			sampler2D _NormalMap;
			float4 _NormalMap_ST;
			sampler2D _LineMap;
			float4 _LineMap_ST;
			sampler2D _EmissionMap;
			float4 _EmissionMap_ST;

			fixed _IsOutline;
			half _OutlineWidth;
			fixed4 _OutlineColor;

			sampler2D _CameraDepthNormalsTexture;

			struct a2v{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord0:TEXCOORD0;
				float4 texcoord1:TEXCOORD1;
				float4 texcoord2:TEXCOORD2;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				float4 uv0:TEXCOORD0;
				float4 uv1:TEXCOORD1;

				float4 T2W0:TEXCOORD2;
				float4 T2W1:TEXCOORD3;
				float4 T2W2:TEXCOORD4;

				SHADOW_COORDS(5)
			};


			v2f vert(a2v v){
				v2f o;
				o.pos=UnityObjectToClipPos(v.vertex);
				o.uv0.xy=v.texcoord0.xy*_AlbedoMap_ST.xy+_AlbedoMap_ST.zw;
				o.uv0.zw=v.texcoord0.xy*_NormalMap_ST.xy+_NormalMap_ST.zw;  

				o.uv1.xy=v.texcoord1.xy*_LineMap_ST.xy+_LineMap_ST.zw;
				o.uv1.zw=v.texcoord2.xy*_EmissionMap_ST.xy+_EmissionMap_ST.zw;

				float3 worldPos=mul(unity_ObjectToWorld,v.vertex.xyz);
				fixed3 worldNormal=UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent=UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal=cross(worldNormal,worldTangent)*v.tangent.w;

				o.T2W0=float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.T2W1=float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.T2W2=float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);

				TRANSFER_SHADOW(o);
				return o;
			}

			float4 frag(v2f i):SV_Target{
				float3 worldPos=float3(i.T2W0.w,i.T2W1.w,i.T2W2.w);
				fixed3 worldLightDir=normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 worldViewDir=normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 tangentNormal=UnpackNormal(tex2D(_NormalMap,i.uv0.zw));
				fixed3 worldNormal=normalize(half3(dot(i.T2W0.xyz,tangentNormal),dot(i.T2W1.xyz,tangentNormal),dot(i.T2W2.xyz,tangentNormal)));

				fixed3 halfDir=normalize(worldLightDir+worldViewDir);
				fixed shadow=SHADOW_ATTENUATION(i);			
				fixed3 ambient=UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed diffuseSmoothStep=smoothstep(0.29,0.3,dot(worldLightDir,worldNormal)*step(0.7,shadow));			
				//Rim HighLighting Part
				float fresnel=pow((1.0-saturate(dot(worldNormal,worldViewDir))),_FresnelPower);
				float faceToLightAdjust=(1-saturate(dot(worldViewDir,-worldLightDir)+0.2))+0.2;
				fixed fresnelStep=step(faceToLightAdjust+0.2,fresnel);
				fixed fresnelOutput=saturate(diffuseSmoothStep*fresnelStep);

				//Diffuse Part
				fixed3 albedoBase=tex2D(_AlbedoMap,i.uv0.xy)*_LightColor0.xyz;
				float  diffuseLight=Remap(0,1,0.2,0.9,diffuseSmoothStep)+step(faceToLightAdjust,fresnel);

				//Specular Part
				float  specularBase=Remap(0,1,-1,-0.9,_SpecularSize)+dot(halfDir,worldNormal)*step(0.7,shadow);
				fixed3 specularLine=tex2D(_LineMap,mul(Rot2D(_RotateAngle),i.uv1.xy-0.5));
				fixed3 specularOutput=smoothstep(0.01,0.02,(specularBase*specularLine))*_SpecularStrength*diffuseSmoothStep;
				
				//Emission Part
				fixed3 emissionOutput=tex2D(_EmissionMap,i.uv1.zw)*_EmissionMultiplier+1;


				//Merge all Parts
				float3 output=((specularOutput+diffuseLight)*albedoBase*1.5+fresnelOutput)*emissionOutput;

				return float4(output*ambient,1.0);			
			}

			v2f vertEdge(a2v v){
				v2f o;
				if(_IsOutline==0){
					_OutlineWidth=0;
				}
				v.vertex.xyz+=v.normal*_OutlineWidth;
				o.pos=UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 fragEdge(v2f i):SV_Target{
				return _OutlineColor;
			}

		ENDCG

		Tags{"Queue"="Transparent" "RenderType"="Opaque"}

		Pass{
			ZWrite Off Cull Front
			CGPROGRAM
			#pragma vertex vertEdge
			#pragma fragment fragEdge
			ENDCG
		}
		Pass{
			Tags{"LightMode"="ForwardBase"} 
			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag		
			ENDCG
		}

	}
	FallBack "Specular"
}
