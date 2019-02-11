//基础噪声
//原理参考：
//https://blog.csdn.net/candycat1992/article/details/50346469
#ifndef NOISE
#define NOISE

#include "Hash.cginc"

sampler2D _NoiseTex;

#if defined(USING_PERLIN_NOISE)
	#define Noise PNoise
#elif defined(USING_VALUE_NOISE)
	#define Noise VNoise
#elif defined(USING_SIMPLEX_NOISE)
	#define Noise SNoise
#else
	#define Noise PNoise
#endif
//Perlin_Noise
float PNoise(float2 p){
	float2 i=floor(p);
	float2 f=frac(p);

	//缓和曲线，计算权重
	float2 w=f*f*(3.0-2.0*f);
	//二阶导连续缓和曲线
	//float2 w=f*f*f*(6*f*f-15*f+10);

	//使用权重值计算插值
	return lerp( lerp(dot(Hash22(i+float2(0.0,0.0)),f-float2(0.0,0.0)),
							   dot(Hash22(i+float2(1.0,0.0)),f-float2(1.0,0.0)),w.x),
						lerp(dot(Hash22(i+float2(0.0,1.0)),f-float2(0.0,1.0)),
							   dot(Hash22(i+float2(1.0,1.0)),f-float2(1.0,1.0)),w.x),w.y);
}

float PNoise(float3 p){
	float3 i=floor(p);
	float3 f=frac(p);

	float3 w=f*f*(3.0-2.0*f);
	//二阶导连续缓和曲线
	//float3 w=f*f*f*(6*f*f-15*f+10);

	return lerp(lerp(lerp(dot(Hash33(i+float3(0.0,0.0,0.0)),f-float3(0.0,0.0,0.0)),
									 dot(Hash33(i+float3(1.0,0.0,0.0)),f-float3(1.0,0.0,0.0)),w.x),
							  lerp(dot(Hash33(i+float3(0.0,1.0,0.0)),f-float3(0.0,1.0,0.0)),
									  dot(Hash33(i+float3(1.0,1.0,0.0)),f-float3(1.0,1.0,0.0)),w.x),w.y),
					   lerp(lerp(dot(Hash33(i+float3(0.0,0.0,1.0)),f-float3(0.0,0.0,1.0)),
									  dot(Hash33(i+float3(1.0,0.0,1.0)),f-float3(1.0,0.0,1.0)),w.x),
						      lerp(dot(Hash33(i+float3(0.0,1.0,1.0)),f-float3(0.0,1.0,1.0)),
									  dot(Hash33(i+float3(1.0,1.0,1.0)),f-float3(1.0,1.0,1.0)),w.x),w.y),w.z);
}

//Value_Noise 
float VNoise(float2 p){
	float2 i=floor(p);
	float2 f=frac(p);
	//缓和曲线，计算插值点
	float2 w=f*f*(3.0-2.0*f);

	return lerp(lerp(Hash21(i+float2(0.0,0.0)),Hash21(i+float2(1.0,0.0)),w.x),
					  lerp(Hash21(i+float2(0.0,1.0)),Hash21(i+float2(1.0,1.0)),w.x),w.y);
}

float VNoise(float3 p){
	float3 i=floor(p);
	float3 f=frac(p);
	//缓和曲线，计算插值点
	float3 w=f*f*(3.0-2.0*f);

	return lerp(lerp(lerp(Hash33(i+float3(0.0,0.0,0.0)),Hash33(i+float3(1.0,0.0,0.0)),w.x),
							  lerp(Hash33(i+float3(0.0,1.0,0.0)),Hash33(i+float3(1.0,1.0,0.0)),w.x),
					   w.y),
					   lerp(lerp(Hash33(i+float3(0.0,0.0,1.0)),Hash33(i+float3(1.0,0.0,1.0)),w.x),
						      lerp(Hash33(i+float3(0.0,1.0,1.0)),Hash33(i+float3(1.0,1.0,1.0)),w.x),
					    w.y),
				w.z);
}

//Simplex_Noise
float SNoise(float2 p){
	const float K1=0.366025404;  //(sqrt(3)-1)/2
	const float K2=0.211324685; //(3-sqrt(3))/6

	//将输入点进行坐标偏移，向下取整得到原点，转换到超立方体空间
	float2 i=floor(p+(p.x+p.y)*K1);
	//得到转换前输入点到原点距离（单形空间下）
	float2 a=p-(i-(i.x+i.y)*K2);
	//确定顶点在哪个三角形内
	float2 o=(a.x<a.y)?float2(0.0,1.0):float2(1.0,0.0);
	//得到转换前输入点到第二个顶点的距离
	float2 b=a-o+K2;
	//得到转换前输入点到第三个顶点的距离
	float2 c=a-1+2*K2;  

	//根据权重计算每个顶点的贡献度
	float3 h=max((0.5-float3(dot(a,a),dot(b,b),dot(c,c))),0.0);
	float3 n=h*h*h*h*float3(dot(a,Hash22(i)),dot(b,Hash22(i+o)),dot(c,Hash22(i+1.0)));

	//乘以系数，做归一化处理
	return dot(float3(70.0,70.0,70.0),n);
}

float SNoise(float3 p){
	const float K1=0.333333333;  // (sqrt(4)-1)/3
	const float K2=0.166666661; // ((1-1/2))/3

	//将输入点的原点进行坐标偏移，转换到超立方体空间
	float3 i=floor(p+(p.x+p.y+p.z)*K1);
	//得到转换前输入点到原点距离（单形空间下）
	float3 a=p-(i-(i.x+i.y+i.z)*K2);

	//判断单形空间下顶点所在的三角形
	float3 e=step(float3(0.0,0.0,0.0),a-a.yzx);
	float3 i1=e*(1.0-e.zxy);
	float3 i2=1.0-e.zxy*(1.0-e);

	float3 b=a-(i1-1.0*K2);
	float3 c=a-(i2-2.0*K2);
	float3 d=a-(1.0-3.0*K2);

	//根据权重计算每个顶点的贡献度
	float4 h=max(0.6-float4(dot(a,a),dot(b,b),dot(c,c),dot(d,d)),0.0);
	float4 n=h*h*h*h*float4(dot(a,Hash33(i)),dot(b,Hash33(i+i1)),dot(c,Hash33(i+i2)),dot(d,Hash33(i+1.0)));
	//乘以系数，做归一化处理
	return dot(float4(31.316,31.316,31.316,31.316), n);
}

#endif