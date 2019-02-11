#ifndef FEATURE
#define FEATURE

#include "FBM.cginc"
#include "Common.cginc"

//Star����
float3 Stars(float3 rd,float den,float tileNum){
	float3 c=float3(0.,0.,0.);
	float3 p=rd;
	float SIZE=0.5;

	for(int i=0;i<3.;i++){
		//1.������rd���пռ仮��
		float3 q=frac(p*tileNum)-0.5;
		float3 id=floor(p*tileNum);
		float2 rn=Hash33(id).xy;
		//2.ʹ�û�������������������Сsize
		float size=(Hash31(id)*0.2+0.8)*SIZE;
		//3.ʹ�������Сֵsize��һ��Ӱ����˸Ƶ�ʣ�����size��������أ���˲�ͬ�����ڵ�Ƶ�ʿ����������
		float demp=pow(1.-size/SIZE,0.8)*0.45;
		float val=(sin(_Time.y*31.*size)*demp+1-demp)*size;
		//4.���ݵ������������ؾ������ĵľ�����ɫ����
		float c2=1.-smoothstep(0.,val,length(q));
		//5.��������������������ֵ�����ɸѡ�������ܶ�
		c2*=step(rn.x,(.005+i*i*0.001)*den);
		//6.��������������������ֵ�������ɫ���
		c+=c2*(lerp(float3(1.0,0.5,0.1),float3(0.75,0.5,1.),rn.y)*0.25+0.75);
		//7.���Ӳ�����ʹ�����ܶ����ӣ���������ԶС����
		
		p*=1.4;
	}
	return c*c*0.7;
}

float TimeFBM(float2 p,float t){
	float2 f=0.0;
	float s=0.5;
	float sum=0;
	//���ε���
	for(int i=0;i<5;i++){
		//����λ�����ʱ��ƫ��
		p+=t;
		//ÿһ��ʱ��ƫ�Ʋ�ͬ���ﵽ�ֲ���ÿһ�㲻ͬ������Ч��
		t*=1.5;
		//������������������ͨ��
		//f+=s*tex2D(_NoiseTex,p/256).x;
		f+=s*VNoise(p);
		//����������ת������������
		p=mul(float2x2(0.8,-0.6,0.6,0.8),p)*2.02;
		//FBMϵ������
		sum+=s;
		s*=0.6;
	}
	return f/sum;
}

//�Ʋ����
float3 Cloud(float3 bgCol,float3 ro,float3 rd,float3 cloudCol,float spd,float layer){
	float3 col=bgCol;
	float time=_Time.y*0.05*spd;
	//��ͬ���Ʋ�ֲ� ��Ӳ�ͬ�Ļ����߶�
	for(int i=0;i<layer;i++){
		//����������rd.xz/rd.y������ʹ��ͬһ��xz��Բ������,����rd.y��ֵ��������
		//ԽԶ(rd.y��ֵԽС),�仯��Խ�ߣ��ܼ��̶Ⱦ�Խ��
		//float2 sc=rd.xz*((i+3)*40000.0)/(rd.y);
		float2 sc=mul(float2x2(0.8,-0.6,0.6,0.8),rd.xz*((i+3)*40000.0)/(rd.y));
		//�Ʋ���ɫ�뱳��ɫ���
		col=lerp(col,cloudCol,0.5*smoothstep(0.4,0.8,TimeFBM(sc*0.00002,time*(i+3))));
	}
	return col;
}

float3 Sky(float3 ro,float3 rd,float3 lightDir){
	fixed3 col=fixed3(0.0,0.0,0.0);
	float3 light1=normalize(lightDir);
	float sundot=clamp(dot(rd,light1),0.0,1.0);

	//���������ɫ����
	//����rd�ڸ߶ȷ����ϵķ���ֵ������ɫ��ϲ�ֵ
	col=float3(0.2,0.5,0.85)*1.1-rd.y*rd.y*0.5;
	col=lerp(col,0.85*float3(0.7,0.75,0.85),pow(1.0-max(rd.y,0.0),4.0));

	//̫������
	//ָ��̫���ⷽ������powԼ����ǿrd����շ����������
	//�γ�ĳһ�����ڵ���ɫֵ��ǿ,����̫��Ч��
	col+=0.35*float3(1.0,0.2,0.1)*pow(sundot,5.0);
	col+=0.35*float3(1.0,0.3,0.2)*pow(sundot,64.0);
	col+=0.25*float3(1.0,0.8,0.6)*pow(sundot,512.0);

	//��
	col=Cloud(col,ro,rd,float3(1.0,0.9,0.9),1,1);
	//���˵�ƽ�����µĲ���
	col=lerp(col,0.68*float3(0.4,0.65,1.0),pow(1.0-max(rd.y,0.0),16.0));

	return col;
}

//���̸��������ɼ�����
// http://iquilezles.org/www/articles/checkerfiltering/checkerfiltering.htm
fixed CheckersGradBox( in fixed2 p )
{
    // filter kernel
    fixed2 w = fwidth(p) + 0.001;
    // analytical integral (box filter)
    fixed2 i = 2.0*(abs(frac((p-0.5*w)*0.5)-0.5)-abs(frac((p+0.5*w)*0.5)-0.5))/w;
    // xor pattern
    return 0.5 - 0.5*i.x*i.y;                  
}
#endif