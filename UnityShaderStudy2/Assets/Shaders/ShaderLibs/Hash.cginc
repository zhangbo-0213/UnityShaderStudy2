//Hash 随机函数
#ifndef HASH
#define HASH

#include "Math.cginc"

//https://www.shadertoy.com/view/4ssXRX   一些指定分布的Hash
//https://www.shadertoy.com/view/4djSRW  不使用三角函数实现的Hash

#define HASHSCALE1 .1031
#define HASHSCALE3 float3(.1031,.1030,.0973)
#define HASHSCALE4 float4(.1031,.1030,.0973,.1099)

//1 in ,1 out 
float Hash11(float p){
	float3 p3=frac(p.xxx*HASHSCALE1);
	p3+=dot(p3,p3.yzx+19.19);
	return frac((p3.x+p3.y)*p3.z);
}

//2 in 1 out
float Hash21(float2 p2){
	float3 p3=frac(float3(p2.xyx)*HASHSCALE1);
	p3+=dot(p3,p3.yzx+19.19);
	return frac((p3.x+p3.y)*p3.z);
}

//3 in 1 out
float Hash31(float3 p3){
	p3=frac(p3*HASHSCALE1);
	p3+=dot(p3,p3.yzx+19.19);
	return frac((p3.x+p3.y)*p3.z);
}

//1 in 2 out
float2 Hash12(float p){
	float3  p3=frac(p*HASHSCALE3);
	p3+=dot(p3,p3.yzx+19.19);
	return frac((p3.xx+p3.yz)*p3.zy);
} 

// 2 in 2 out
float2 Hash22(float2 p2){
	float3 p3=frac(float3(p2.xyx)*HASHSCALE3);
	p3+=dot(p3,p3.yzx+19.19);
	return frac((p3.xx+p3.yz)*p3.zy);
}

//3 in 2 out
float2 Hash32(float3 p3){
	p3=frac(p3*HASHSCALE3);
	p3+=dot(p3,p3.yzx+19.19);
	return frac((p3.xx+p3.yz)*p3.zy);
}

//1 in 3 out
float3 Hash13(float p){
	float3 p3=frac(p*HASHSCALE3);
	p3+=dot(p3,p3.yzx+19.19);
	return frac((p3.xxy+p3.yzz)*p3.zyx);
}

//2 in 3 out 
float3 Hash23(float2 p2){
	float3 p3=frac(float3(p2.xyx)*HASHSCALE3);
	p3+=dot(p3,p3.yxz+19.19);
	return frac((p3.xxy+p3.yzz)*p3.zyx);
}

//3 in 3 out
float3 Hash33(float3 p3){
	p3=frac(p3*HASHSCALE3);
	p3+=dot(p3,p3.yxz+19.19);
	return frac((p3.xxy+p3.yzz)*p3.zyx);
}

//1 in 4 out
float4 Hash14(float p){
	float4 p4=frac(p*HASHSCALE4);
	p4+=dot(p4,p4.wzxy+19.19);
	return frac((p4.xxyz+p4.yzzw)*p4.zywx);
}

//2 in 4 out
float4 Hash24(float2 p2){
	float4 p4=frac(float4(p2.xyxy)*HASHSCALE4);
	p4+=dot(p4,p4.wzxy+19.19);
	return frac((p4.xxyz+p4.yzzw)*p4.zywx);
}

//3 in 4 out
float4 Hash34(float3 p3){
	float4 p4=frac(float4(p3.xyzx)*HASHSCALE4);
	p4+=dot(p4,p4.wzxy+19.19);
	return frac((p4.xxyz+p4.yzzw)*p4.zywx);
}

//4 in 4 out
float4 Hash44(float4 p4){
	p4=frac(p4*HASHSCALE4);
	p4+=dot(p4,p4.wzxy+19.19);
	return frac((p4.xxyz+p4.yzzw)*p4.zywx);
}

#endif