#include <math.h>

void umbralizar_c (
	unsigned char *src,
	unsigned char *dst,
	int h,
	int w,
	int row_size,
	unsigned char min,
	unsigned char max,
	unsigned char q
) {
	unsigned char (*src_matrix)[row_size] = (unsigned char (*)[row_size]) src;
	unsigned char (*dst_matrix)[row_size] = (unsigned char (*)[row_size]) dst;
	int i, j;
	for (i=0; i<h; ++i){
		for(j=0; j<w; j++){
			if(src_matrix[i][j] < min){
				dst_matrix[i][j] = 0;
			} else if (src_matrix[i][j] > max){
				dst_matrix[i][j] = 255;
			} else{
				dst_matrix[i][j] = (src_matrix[i][j]/q)*q;
			}
		}
	}
}
