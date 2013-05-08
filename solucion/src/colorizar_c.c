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
	int i, j, l, k, maximo;
	
	for(i=1; i<h; ++i){
		for (j=3; j < 3*w; j+=3){
			int maximoR, maximoB, maximoG = 0;
			
			for(k=-1; k<1; ++k){	//Busco el maximoR
				for (l=-3; l < 3; l+=3){	
					if(maximoR < src_matrix[i+k][j+2+l]){
						maximoR = src_matrix[i+k][j+2+l];
					}
				}
			}
			for(k=-1; k<1; ++k){	//Busco el maximoG
				for (l=-3; l < 3; l+=3){	
					if(maximoG < src_matrix[i+k][j+1+l]){
						maximoG = src_matrix[i+k][j+1+l];
					}
				}
			}
			for(k=-1; k<1; ++k){	//Busco el maximoB
				for (l=-3; l < 3; l+=3){	
					if(maximoB < src_matrix[i+k][j+0+l]){
						maximoB = src_matrix[i+k][j+0+l];
					}
				}
			}

			//Llamamos 0 a B, 1 a G y 2 a R 
			if(maximoR >= maximoG && maximoR >= maximoB)
				maximo = 2;
			if(maximoR < maximoG && maximoG >= maximoB)
				maximo = 1;
			if(maximoR < maximoB && maximoR < maximoB)
				maximo = 0;

			float fcR, fcB, fcG;
			switch (maximo){
				case 0:
					fcB = (1+alpha);
					fcG = (1-alpha);
					fcR = (1-alpha);
					break;
				case 1:
					fcB = (1-alpha);
					fcG = (1+alpha);
					fcR = (1-alpha);
					break;
				case 2:
					fcB = (1-alpha);
					fcG = (1-alpha);
					fcR = (1+alpha);
					break;
			}

			int val = fcB*src_matrix[i][j];
			if(val < 255){
				dst_matrix[i][j] = val;
			} else {
				dst_matrix[i][j] = 255;
			}
			val = fcG*src_matrix[i][j+1];
			if(val < 255){
				dst_matrix[i][j+1] = val;
			} else {
				dst_matrix[i][j+1] = 255;
			}
			val = fcR*src_matrix[i][j+2];
			if(val < 255){
				dst_matrix[i][j+2] = val;
			} else {
				dst_matrix[i][j+2] = 255;
			}
			
		}
	}
}
