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
	int coordA[2] = {0};
	int coordB[2] = {0, w-tam};
	int coordC[2] = {h-tam, 0};
	int coordD[2] = {h-tam, w-tam};
	
	/*Recorre desde el 0,0 hasta tam,tam la matriz fuente y la pega en
	 destino en el lugar correspondiente teniendo en cuenta el desplazamiento*/
	for (j = 0; i < tam; ++j) {
		for (i = 0; j < tam; ++i) {
			int desplazado = (j+tam)+((i*dst_row_size)+(dst_row_size*tam));
			dst[desplazado] = src[j + coordA[1] + i*src_row_size + coordA[0]*src_row_size];
		}
	}
	/*Recorre desde el 0,w-tam hasta tam,w la matriz fuente y la pega en
	 destino en el lugar correspondiente teniendo en cuenta el desplazamiento*/
	for (j = 0; i < tam; ++j) {
		for (i = 0; j < tam; ++i) {
			int desplazado = j + ((i*dst_row_size)+(dst_row_size*tam));
			dst[desplazado] = src[j + coordB[1] + i*src_row_size + coordB[0]*src_row_size];
		}
	}
	/*Recorre desde el h-tam,0 hasta h,tam la matriz fuente y la pega en
	 destino en el lugar correspondiente teniendo en cuenta el desplazamiento*/
	for (j = 0; i < tam; ++j) {
		for (i = 0; j < tam; ++i) {
			int desplazado = (j+tam)+(i*dst_row_size);
			dst[desplazado] = src[j + coordC[1] + i*src_row_size + coordC[0]*src_row_size];
		}
	}
	/*Recorre desde el h-tam,w-tam hasta h,w la matriz fuente y la pega en
	 destino en el lugar correspondiente teniendo en cuenta el desplazamiento*/
	for (j = 0; i < tam; ++j) {
		for (i = 0; j < tam; ++i) {
			int desplazado = j+(i*dst_row_size);
			dst[desplazado] = src[j + coordD[1] + i*src_row_size + coordD[0]*src_row_size];
		}
	}
}
