void recortar_c (
	unsigned char *src,
	unsigned char *dst,
	int h,
	int w,
	int src_row_size,
	int dst_row_size,
	int tam
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

	int i, j;
	//i es la fila, j es la columna
/*	int coordA[2] = {0};
	int coordB[2] = {0, w-tam};
	int coordC[2] = {h-tam, 0};
	int coordD[2] = {h-tam, w-tam};
	
	Recorre desde el 0,0 hasta tam,tam la matriz fuente y la pega en
	 destino en el lugar correspondiente teniendo en cuenta el desplazamiento*/
	for (j = 0; j < tam; ++j) {
		for (i = 0; i < tam; ++i) {
			dst_matrix[i+tam][j+tam] = src_matrix[i][j];
		}
	}
	/*Recorre desde el 0,w-tam hasta tam,w la matriz fuente y la pega en
	 destino en el lugar correspondiente teniendo en cuenta el desplazamiento*/
	for (j = 0; j < tam; ++j) {
		for (i = 0; i < tam; ++i) {
			dst_matrix[i+tam][j] = src_matrix[i][w-tam+j];
		}
	}
	/*Recorre desde el h-tam,0 hasta h,tam la matriz fuente y la pega en
	 destino en el lugar correspondiente teniendo en cuenta el desplazamiento*/
	for (j = 0; j < tam; ++j) {
		for (i = 0; i < tam; ++i) {
		
			dst_matrix[i][tam+j] = src_matrix[i+h-tam][j];
		}
	}
	/*Recorre desde el h-tam,w-tam hasta h,w la matriz fuente y la pega en
	 destino en el lugar correspondiente teniendo en cuenta el desplazamiento*/
	for (j = 0; j < tam; ++j) {
		for (i = 0; i < tam; ++i) {
			dst_matrix[i][j] = src_matrix[i+h-tam][j+w-tam];
		}
	}
}
