//分形噪声
#ifndef FBM
#define FBM

#include "Noise.cginc"

float Noise_Self(float2 p){
	return Noise(p*8.0);
}

//叠加5层，并把初始化采样距离设置为7，可以自定义。这种噪声可以用来模拟石头、山脉这类物体。
float Noise_Sum(float2 p){
	float f=0.0;
	p=p*7.0;
	f+=1.0000*Noise(p);p=2.0*p;
	f+=0.5000*Noise(p);p=2.0*p;
	f+=0.2500*Noise(p);p=2.0*p;
	f+=0.1250*Noise(p);p=2.0*p;
	f+=0.0625*Noise(p);p=2.0*p;
	return f;
}

//由于进行了绝对值操作，因此会在0值变化处出现不连续性，形成一些尖锐的效果。
//通过合适的颜色叠加，可以用这种噪声来模拟火焰、云朵这些物体。
//Perlin把这个公式称为turbulence（湍流？），因为它看起来挺像的
float Noise_Sum_Abs(float2 p){
	float f=0.0;
	p=p*7.0;
	f+=1.0000*abs(Noise(p));p=2.0*p;
	f+=0.5000*abs(Noise(p));p=2.0*p;
	f+=0.2500*abs(Noise(p));p=2.0*p;
	f+=0.1250*abs(Noise(p));p=2.0*p;
	f+=0.0625*abs(Noise(p));p=2.0*p;
	return f;
}

//这个公式可以让表面沿着x方向形成一个条纹状的结构。Perlin使用这个公式模拟了一些大理石材质。
float Noise_Sum_Abs_Sin(float2 p){
	float f=0.0;
	p=p*7.0;
	f+=1.0000*abs(Noise(p));p=2.0*p;
	f+=0.5000*abs(Noise(p));p=2.0*p;
	f+=0.2500*abs(Noise(p));p=2.0*p;
	f+=0.1250*abs(Noise(p));p=2.0*p;
	f+=0.0625*abs(Noise(p));p=2.0*p;

	f=sin(f+p.x/32.0);

	return f;
}

float Noise_Self(float3 p){
	return Noise(p*8.0);
}

//叠加5层，并把初始化采样距离设置为7，可以自定义。这种噪声可以用来模拟石头、山脉这类物体。
float Noise_Sum(float3 p){
	float f=0.0;
	p=p*7.0;
	f+=1.0000*Noise(p);p=2.0*p;
	f+=0.5000*Noise(p);p=2.0*p;
	f+=0.2500*Noise(p);p=2.0*p;
	f+=0.1250*Noise(p);p=2.0*p;
	f+=0.0625*Noise(p);p=2.0*p;
	return f;
}

//由于进行了绝对值操作，因此会在0值变化处出现不连续性，形成一些尖锐的效果。
//通过合适的颜色叠加，可以用这种噪声来模拟火焰、云朵这些物体。
//Perlin把这个公式称为turbulence（湍流？），因为它看起来挺像的
float Noise_Sum_Abs(float3 p){
	float f=0.0;
	p=p*7.0;
	f+=1.0000*abs(Noise(p));p=2.0*p;
	f+=0.5000*abs(Noise(p));p=2.0*p;
	f+=0.2500*abs(Noise(p));p=2.0*p;
	f+=0.1250*abs(Noise(p));p=2.0*p;
	f+=0.0625*abs(Noise(p));p=2.0*p;
	return f;
}

//这个公式可以让表面沿着x方向形成一个条纹状的结构。Perlin使用这个公式模拟了一些大理石材质。
float Noise_Sum_Abs_Sin(float3 p){
	float f=0.0;
	p=p*7.0;
	f+=1.0000*abs(Noise(p));p=2.0*p;
	f+=0.5000*abs(Noise(p));p=2.0*p;
	f+=0.2500*abs(Noise(p));p=2.0*p;
	f+=0.1250*abs(Noise(p));p=2.0*p;
	f+=0.0625*abs(Noise(p));p=2.0*p;

	f=sin(f+p.x/32.0);

	return f;
}

#endif