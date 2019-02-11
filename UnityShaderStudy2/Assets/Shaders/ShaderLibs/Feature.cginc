#ifndef FEATURE
#define FEATURE

#include "FBM.cginc"
#include "Common.cginc"

//Star绘制
float3 Stars(float3 rd,float den,float tileNum){
	float3 c=float3(0.,0.,0.);
	float3 p=rd;
	float SIZE=0.5;

	for(int i=0;i<3.;i++){
		//1.先利用rd进行空间划分
		float3 q=frac(p*tileNum)-0.5;
		float3 id=floor(p*tileNum);
		float2 rn=Hash33(id).xy;
		//2.使用划分网格坐标产生随机大小size
		float size=(Hash31(id)*0.2+0.8)*SIZE;
		//3.使用随机大小值size进一步影响闪烁频率，由于size与网格相关，因此不同网格内的频率可以做到随机
		float demp=pow(1.-size/SIZE,0.8)*0.45;
		float val=(sin(_Time.y*31.*size)*demp+1-demp)*size;
		//4.根据单个网格内像素距离中心的距离着色区分
		float c2=1.-smoothstep(0.,val,length(q));
		//5.利用网格坐标产生的随机值做随机筛选，控制密度
		c2*=step(rn.x,(.005+i*i*0.001)*den);
		//6.利用网格坐标产生的随机值做随机颜色混合
		c+=c2*(lerp(float3(1.0,0.5,0.1),float3(0.75,0.5,1.),rn.y)*0.25+0.75);
		//7.增加层数并使网格密度增加，产生近大远小差异
		
		p*=1.4;
	}
	return c*c*0.7;
}

float TimeFBM(float2 p,float t){
	float2 f=0.0;
	float s=0.5;
	float sum=0;
	//分形叠加
	for(int i=0;i<5;i++){
		//采样位置添加时间偏移
		p+=t;
		//每一层时间偏移不同，达到分层下每一层不同的移速效果
		t*=1.5;
		//噪声纹理采样结果，单通道
		//f+=s*tex2D(_NoiseTex,p/256).x;
		f+=s*VNoise(p);
		//采样点做旋转，产生流动感
		p=mul(float2x2(0.8,-0.6,0.6,0.8),p)*2.02;
		//FBM系数操作
		sum+=s;
		s*=0.6;
	}
	return f/sum;
}

//云层绘制
float3 Cloud(float3 bgCol,float3 ro,float3 rd,float3 cloudCol,float spd,float layer){
	float3 col=bgCol;
	float time=_Time.y*0.05*spd;
	//不同的云层分层 添加不同的基本高度
	for(int i=0;i<layer;i++){
		//采样坐标与rd.xz/rd.y关联，使得同一个xz的圆截面下,根据rd.y的值连续采样
		//越远(rd.y的值越小),变化率越高，密集程度就越大
		//float2 sc=rd.xz*((i+3)*40000.0)/(rd.y);
		float2 sc=mul(float2x2(0.8,-0.6,0.6,0.8),rd.xz*((i+3)*40000.0)/(rd.y));
		//云层颜色与背景色混合
		col=lerp(col,cloudCol,0.5*smoothstep(0.4,0.8,TimeFBM(sc*0.00002,time*(i+3))));
	}
	return col;
}

float3 Sky(float3 ro,float3 rd,float3 lightDir){
	fixed3 col=fixed3(0.0,0.0,0.0);
	float3 light1=normalize(lightDir);
	float sundot=clamp(dot(rd,light1),0.0,1.0);

	//基本天空颜色过渡
	//利用rd在高度方向上的分量值进行颜色混合插值
	col=float3(0.2,0.5,0.85)*1.1-rd.y*rd.y*0.5;
	col=lerp(col,0.85*float3(0.7,0.75,0.85),pow(1.0-max(rd.y,0.0),4.0));

	//太阳绘制
	//指定太阳光方向，利用pow约束增强rd与光照方向点积结果，
	//形成某一区域内的颜色值较强,绘制太阳效果
	col+=0.35*float3(1.0,0.2,0.1)*pow(sundot,5.0);
	col+=0.35*float3(1.0,0.3,0.2)*pow(sundot,64.0);
	col+=0.25*float3(1.0,0.8,0.6)*pow(sundot,512.0);

	//云
	col=Cloud(col,ro,rd,float3(1.0,0.9,0.9),1,1);
	//过滤地平线以下的部分
	col=lerp(col,0.68*float3(0.4,0.65,1.0),pow(1.0-max(rd.y,0.0),16.0));

	return col;
}

//棋盘格纹理生成及过滤
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