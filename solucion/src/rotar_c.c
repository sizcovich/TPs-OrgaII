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
	
	double sqrt2 = sqrt(2.0)/2.0;
	
	int cx = floor(w/2.0);
	int cy = floor(h/2.0);
	for (int i=0; i < w; ++i){
		for (int j=0; j < h; ++j){
			
			double dx = i - cx;
			double dy = j - cy;
			
			int u = cx + (sqrt2 * dx) - (sqrt2 * dy);
			int v = cy + (sqrt2 * dx) + (sqrt2 * dy);
			
			if ((0 <= u && u < w) && (0 <= v && v < h) ){
				dst_matrix[j][i] = src_matrix[v][u];
			}else{
				dst_matrix[j][i] = 0;
			}
		}
	}
}
