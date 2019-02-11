#ifndef FRAMEWORK_3D_DEFAULT_SCENE
#define FRAMEWORK_3D_DEFAULT_SCENE

#include "SDF.cginc"
#include "FrameWork3D.cginc"

float3 MatCol(float matID,float3 pos,float3 nor);
float2 Map(in float3 pos);
float3 Render(in float3 ro,in float3 rd);

float2 RayCast(float3 ro,float3 rd){
	_MACRO_RAY_CAST(ro,rd,1000.0,Map);
}

float3 CalcNormal(in float3 pos,float rz){
	_MACRO_CALC_NORMAL(pos,rz,Map);
}

float SoftShadow(in float3 ro,in float3 rd,float tmax){
	_MACRO_SOFT_SHADOW(ro,rd,tmax,Map);
}

// Ambient Occlusion: 环境光吸收/遮蔽
float CalcAO(in float3 pos,in float3 nor){
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        float3 aopos =  nor * hr + pos;
        float dd = Map( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );
}

#ifdef DEFAULT_RENDER
float3 Render(in float3 ro,in float3 rd){
	float3 col=float3(0.7,0.8,1.0)+rd.y*0.8;
	float2 res=RayCast(ro,rd);
	float t=res.x;
	float m=res.y;
	//碰撞到场景中的物体
	if(m>-0.5){
		float3 pos=ro+t*rd;
		float3 nor=CalcNormal(pos,0.01);
		float3 ref=reflect(rd,nor);
		col=MatCol(m,pos,nor);

		//Lighting 光照着色计算
		float occ=CalcAO(pos,nor); //环境光遮蔽
		float3 lig=normalize(float3(-0.4,0.7,-0.6));
		float3 hal=normalize(lig-rd); //halfLitDir
		float amb=clamp(0.5+0.5*nor.y,0.0,1.0);
		float dif=clamp(dot(nor,lig),0.0,1.0);
		float bac=clamp(dot(nor,normalize(float3(-lig.x,0.0,-lig.z))),0.0,1.0)*clamp(1.0-pos.y,0.0,1.0);//计算背光
		float dom=smoothstep(-0.01,0.01,ref.y);//计算反射方向上的影响因子
		float fre=pow(clamp(1.0-dot(nor,rd),0.0,1.0),2.0);//菲涅尔边缘高光

		dif*=SoftShadow(pos,lig,2.5);//沿着光线方向上指定范围内有物体，添加阴影
		dom*=SoftShadow(pos,ref,2.5);//沿着光线反射方向上指定范围内若有物体，添加阴影

		float spe=pow(clamp(dot(nor,hal),0.0,1.0),16.0)*dif*(0.04+0.96*pow(clamp(1.0+dot(hal,rd),0.0,1.0),5.0));//更复杂的高光计算模型

		float3 lin=float3(0.0,0.0,0.0);
		lin+=1.30*dif*float3(1.00,0.80,0.55);
		lin+=0.40*amb*float3(0.40,0.60,1.00)*occ;
		lin+=0.50*dom*float3(0.30,0.70,1.00)*occ;
		lin+=0.50*bac*float3(0.25,0.25,0.25)*occ;
		lin+=0.25*fre*float3(1.00,1.00,1.00)*occ;
		col=col*lin;
		col+=10.00*spe*float3(1.00,0,0);

		//根据光线检测距离非线性插值背景
		col=lerp(col,float3(0.8,0.9,1.0),1.0-exp(-0.0002*t*t*t));	
	}
	return float3(clamp(col,0.0,1.0));
}
#endif

#ifdef DEFAULT_MAT_COL
float3 MatCol(float matID,float3 pos,float3 nor){
	float3 col=0.45+0.35*sin(float3(0.05,0.08,0.10)*(matID-1.0));
	if(matID<1.5){
		//CheckersGradBox 棋盘纹理绘制
		float f=CheckersGradBox(5.0*pos.xz);
		col=0.3+f*float3(0.1,0.1,0.1);
	}
	return col;
}
#endif

#ifdef DEFAULT_PROCESS_FRAG
float4 ProcessRayMarch(float2 uv,float3 ro,float3 rd,inout float sceneDep,float4 sceneCol){
	//render
	float3 col=Render(ro,rd);
	//gamma矫正
	col=pow(col,float3(0.4545,0.4545,0.4545));
	sceneCol.xyz=col;
	return sceneCol;
}	
#endif

#endif //FRAMEWORK_3D_DEFAULT_SCENE

