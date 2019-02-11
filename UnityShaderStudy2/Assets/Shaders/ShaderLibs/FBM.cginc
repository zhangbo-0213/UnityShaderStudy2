//��������
#ifndef FBM
#define FBM

#include "Noise.cginc"

float Noise_Self(float2 p){
	return Noise(p*8.0);
}

//����5�㣬���ѳ�ʼ��������������Ϊ7�������Զ��塣����������������ģ��ʯͷ��ɽ���������塣
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

//���ڽ����˾���ֵ��������˻���0ֵ�仯�����ֲ������ԣ��γ�һЩ�����Ч����
//ͨ�����ʵ���ɫ���ӣ�����������������ģ����桢�ƶ���Щ���塣
//Perlin�������ʽ��Ϊturbulence��������������Ϊ��������ͦ���
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

//�����ʽ�����ñ�������x�����γ�һ������״�Ľṹ��Perlinʹ�������ʽģ����һЩ����ʯ���ʡ�
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

//����5�㣬���ѳ�ʼ��������������Ϊ7�������Զ��塣����������������ģ��ʯͷ��ɽ���������塣
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

//���ڽ����˾���ֵ��������˻���0ֵ�仯�����ֲ������ԣ��γ�һЩ�����Ч����
//ͨ�����ʵ���ɫ���ӣ�����������������ģ����桢�ƶ���Щ���塣
//Perlin�������ʽ��Ϊturbulence��������������Ϊ��������ͦ���
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

//�����ʽ�����ñ�������x�����γ�һ������״�Ľṹ��Perlinʹ�������ʽģ����һЩ����ʯ���ʡ�
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