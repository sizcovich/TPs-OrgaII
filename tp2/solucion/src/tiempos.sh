#!/bin/sh

TESTINFILE=../data/test-in/test.in
TESTINDIR=../data/test-in
TESTSIZE=10000

echo 'Comparacion de rendimiento: '

while read f;
do
	file=$TESTINDIR/$f

	echo '\nProcesando archivo: ' $file '\n'

	# recortar
#	echo '\n###########################################################'
#	echo '\nRecortar tamaño 100: \n'
#	./rendimiento.py $TESTSIZE recortar $file 100
#	echo '\n###########################################################'


	# halftone
#	echo '\n###########################################################'
#	echo '\nHalftone: \n'
#	./rendimiento.py $TESTSIZE halftone $file
#	echo '\n###########################################################'


	## colorizar
	echo '\n###########################################################'
	echo '\nColorizar alpha 0,5: \n'
	./rendimiento.py $TESTSIZE colorizar $file 0.5
	echo '\n###########################################################'


	## umbralizar
#echo '\n###########################################################'
#	echo '\nUmbralizar minimo 64 maximo 128 q 16: \n'
#	./rendimiento.py $TESTSIZE umbralizar $file 64 128 16
#	echo '\n###########################################################'


#	## waves
#	echo '\n###########################################################'
#	echo '\nWaves x_scale 16 y_scale 8 g_scale 15: \n'
#	./rendimiento.py $TESTSIZE waves $file 16 8 15
#	echo '\n###########################################################'


	## waves
#	echo '\n###########################################################'
#	echo '\nRotar: \n'
#	./rendimiento.py $TESTSIZE rotar $file
#	echo '\n###########################################################'
done < $TESTINFILE
