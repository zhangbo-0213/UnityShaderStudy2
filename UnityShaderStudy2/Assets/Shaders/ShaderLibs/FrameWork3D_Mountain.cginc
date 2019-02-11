#ifndef FRAMEWORK_3D_Mountain
#define FRAMEWORK_3D_Mountain

#include "FrameWork3D.cginc"
#include "FBM.cginc"

float2 TerrainMap_L(float3 pos);
float2 TerrainMap_M(float3 pos);
float2 TerrainMap_H(float3 pos);

//Raycast中在做光线步进是会循环多次，为简化计算采用低精度的Map函数
float RaycastTerrain(float3 ro,float3 rd){
	_MACRO_RAY_CAST(ro,rd,10000,TerrainMap_L);
}

//法线计算过程中只有一次，因此采用高精度Map函数
float3 NormalTerrain(in float3 pos,float rz){
	_MACRO_CALC_NORMAL(pos,rz,TerrainMap_H);
}

//阴影计算过程中步进函数的次数少于Raycast，采用中精度的MAP函数
float SoftShadow(in float3 ro,in float3 rd,float tmax){
	_MACRO_SOFT_SHADOW(ro,rd,tmax,TerrainMap_M);
}

#endif

