#include <math.h>

float sin_taylor (float x) {
	const float pi = 3.14159265359;
    int k = floor(x/(2*pi));
    float r = x - (k*2*pi);
    x = r - pi;
    return x - pow(x, 3)/6 + pow(x, 5)/120 - pow(x, 7)/5040
}

void waves_c (
	unsigned char *src,
	unsigned char *dst,
	int h,
	int w,
	int row_size,
	float x_scale,
	float y_scale,
	float g_scale
) {
	unsigned char (*src_matrix)[row_size] = (unsigned char (*)[row_size]) src;
	unsigned char (*dst_matrix)[row_size] = (unsigned char (*)[row_size]) dst;
    int i, j, saturacion;
    for (i=0; i < h; ++i){
		for (j=0; j < w; ++j){
            double prof = (x_scale*sin_taylor(i/8.0) + y_scale*sin_taylor(j/8.0))/2;
            saturacion = prof*g_scale + src_matrix[i][j];
            if (saturacion<0){
                dst_matrix[i][j] = 0;
            }else if(saturacion>255){
                dst_matrix[i][j] = 255;
            }else{
                dst_matrix[i][j] = saturacion;
            }
        }
    }
}
