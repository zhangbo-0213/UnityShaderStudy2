#define PI 3.14159265359
#define PI2 6.28318530718
#define Deg2Radius PI/180.
#define Radius2Deg 180./PI

float Remap(float oa,float ob,float na,float nb,float val){
	return (val-oa)/(ob-oa) * (nb-na) + na;
}