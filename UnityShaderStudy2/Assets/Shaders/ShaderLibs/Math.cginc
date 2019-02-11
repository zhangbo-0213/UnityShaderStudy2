#ifndef MATH
#define MATH

#define PI 3.14159265359
#define PI2 6.28318530718
#define Deg2Radius PI/180.
#define Radius2Deg 180./PI

float length2( float2 p )
{
    return sqrt( p.x*p.x + p.y*p.y );
}

float length6( float2 p )
{
    p = p*p*p; p = p*p;
    return pow( p.x + p.y, 1.0/6.0 );
}

float length8( float2 p )
{
    p = p*p; p = p*p; p = p*p;
    return pow( p.x + p.y, 1.0/8.0 );
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return lerp( b, a, h ) - k*h*(1.0-h);
}

float Remap(float oa,float ob,float na,float nb,float val){
	return (val-oa)/(ob-oa) * (nb-na) + na;
}

float2x2 Rot2D(float a){
	a*=Deg2Radius;
	float sa=sin(a);
	float ca=cos(a);
	return float2x2(ca,-sa,sa,ca);
}

float2x2 Rot2DRad(float a){
	float sa=sin(a);
	float ca=cos(a);
	return float2x2(ca,-sa,sa,ca);
}

#endif