#ifndef FRAMEWORK_3D_Mountain
#define FRAMEWORK_3D_Mountain

#include "FrameWork3D.cginc"
#include "FBM.cginc"

float2 TerrainMap_L(float3 pos);
float2 TerrainMap_M(float3 pos);
float2 TerrainMap_H(float3 pos);

//Raycast���������߲����ǻ�ѭ����Σ�Ϊ�򻯼�����õ;��ȵ�Map����
float RaycastTerrain(float3 ro,float3 rd){
	_MACRO_RAY_CAST(ro,rd,10000,TerrainMap_L);
}

//���߼��������ֻ��һ�Σ���˲��ø߾���Map����
float3 NormalTerrain(in float3 pos,float rz){
	_MACRO_CALC_NORMAL(pos,rz,TerrainMap_H);
}

//��Ӱ��������в��������Ĵ�������Raycast�������о��ȵ�MAP����
float SoftShadow(in float3 ro,in float3 rd,float tmax){
	_MACRO_SOFT_SHADOW(ro,rd,tmax,TerrainMap_M);
}

#endif

