#include <math.h>
void rotar_c (
	unsigned char *src,
	unsigned char *dst,
	int h,
	int w,
	int src_row_size,
	int dst_row_size
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
	int i = 0;
	int j = 0;
	int cx = w/2;
	int cy = h/2;
	int u = cx + (sqrt(2)/2)*(i-cx) - (sqrt(2)/2)*(j-cy);
	int v = cy + (sqrt(2)/2)*(i-cx) - (sqrt(2)/2)*(j-cy);
	for (i=0; i < h; i+=2){
		for (j=0; j < w; j+=2){
			if ((0<=u<=w) && (0<=v<=h)){
				dst_matrix[i][j] = src_matrix[u][v];
			}else{
				dst_matrix[i][j] = 0x00;
			}
		}
	}
}
