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
	int i,j;
	int u,v;
	int cx = floor(w/2);
	int cy = floor(h/2);
	for (i=0; i < h; ++i){
		for (j=0; j < w; ++j){
			float dx = (float) i - cx;
			float dy = (float) j - cy;
			u = cx + ((sqrt(2)/2.0) * dx) - ((sqrt(2)/2.0) * dy);
			v = cy + ((sqrt(2)/2.0) * dx) + ((sqrt(2)/2.0) * dy);
			if ((0<=u && u<=w) && (0<=v && v<=h)){
				dst_matrix[i][j] = src_matrix[u][v];
			}else{
				dst_matrix[i][j] = 0x00;
			}
		}
	}
}
