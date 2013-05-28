void colorizar_c (
	unsigned char *src,
	unsigned char *dst,
	int h,
	int w,
	int src_row_size,
	int dst_row_size,
	float alpha
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
	//1er Byte = B, 2do = G, 3ero = R
	int i, j, l, k;
	
	//Completo la primer linea
	for (j = 0; j < (3*w); ++j) {
		dst_matrix[0][j] = src_matrix[0][j];
	}

	for (i = 1; i < (h - 1); ++i) {
		for (j = 0; j < 3; ++j) {
			dst_matrix[i][j] = src_matrix[i][j];
		}

		for (j = 1; j < (w - 1); j += 1) {
			int maximoR, maximoB, maximoG;

			maximoR = 0;
			maximoB = 0;
			maximoG = 0;

			for (k = -1; k <= 1; ++k) {
				for (l = -1; l <= 1; l += 1) {	
					if (maximoR < src_matrix[i+k][(3*(j+l))+2]) {	//Busco el maximoR
						maximoR = src_matrix[i+k][(3*(j+l))+2];
					}

					if (maximoG < src_matrix[i+k][(3*(j+l))+1]) {	//Busco el maximoG
						maximoG = src_matrix[i+k][(3*(j+l))+1];
					}

					if (maximoB < src_matrix[i+k][(3*(j+l))+0]) {	//Busco el maximoB
						maximoB = src_matrix[i+k][(3*(j+l))+0];
					}
				}
			}

			double fcR, fcB, fcG;
			fcR = fcB = fcG = (1-alpha);

			if (maximoR >= maximoG && maximoR >= maximoB) {
				fcR = (1+alpha);
			}
			if (maximoR < maximoG && maximoG >= maximoB) {
				fcG = (1+alpha);
			}
			if (maximoR < maximoB && maximoG < maximoB) {
				fcB = (1+alpha);
			}

			int val = fcB*src_matrix[i][(3*j)];
			if(val < 255){
				dst_matrix[i][(3*j)] = val;
			} else {
				dst_matrix[i][(3*j)] = 255;
			}
			val = fcG*src_matrix[i][(3*j)+1];
			if(val < 255){
				dst_matrix[i][(3*j)+1] = val;
			} else {
				dst_matrix[i][(3*j)+1] = 255;
			}
			val = fcR*src_matrix[i][(3*j)+2];
			if(val < 255){
				dst_matrix[i][(3*j)+2] = val;
			} else {
				dst_matrix[i][(3*j)+2] = 255;
			}
			
		}

		for (j = 3*(w-1); j < (3*w); ++j) {
			dst_matrix[i][j] = src_matrix[i][j];
		}
	}

	for (j = 0; j < (3*w); ++j) {
		dst_matrix[h-1][j] = src_matrix[h-1][j];
	}
}
