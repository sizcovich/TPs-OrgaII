void halftone_c (
	unsigned char *src,
	unsigned char *dst,
	int h,
	int w,
	int src_row_size,
	int dst_row_size
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
	int suma, i, j;
	for (i=0; i < h; i+=2){
		for (j=0; j < w; j+=2){
			suma = src_matrix[i][j] + src_matrix[i][j+1] + src_matrix[i+1][j] + src_matrix[i+1][j+1];
			if(suma < 205){
				dst_matrix[i][j] = 0x00;
				dst_matrix[i][j+1] = 0x00;
				dst_matrix[i+1][j] = 0x00;
				dst_matrix[i+1][j+1] = 0x00;
			} else if(suma < 410){
				dst_matrix[i][j] = 0xFF;
				dst_matrix[i][j+1] = 0x00;
				dst_matrix[i+1][j] = 0x00;
				dst_matrix[i+1][j+1] = 0x00;
			} else if(suma < 615){
				dst_matrix[i][j] = 0xFF;
				dst_matrix[i][j+1] = 0x00;
				dst_matrix[i+1][j] = 0x00;
				dst_matrix[i+1][j+1] = 0xFF;
			} else if(suma < 820){
				dst_matrix[i][j] = 0xFF;
				dst_matrix[i][j+1] = 0x00;
				dst_matrix[i+1][j] = 0xFF;
				dst_matrix[i+1][j+1] = 0xFF;
			} else{
				dst_matrix[i][j] = 0xFF;
				dst_matrix[i][j+1] = 0xFF;
				dst_matrix[i+1][j] = 0xFF;
				dst_matrix[i+1][j+1] = 0xFF;
			}
		}
	}	

}
