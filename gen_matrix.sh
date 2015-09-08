#!/bin/bash

#USO: bash gen_matrix.sh $min $max $nroMatrices
#Se usa un random entre [min-max] para definir el nxm
#ejemplo: bash gen_matrix.sh 1 3 10 -> se tendra diez matrices que podran tener dimensiones de
# 1x1, 1x2, 1x3, 2x3 y 3x3.

min=$1
max=$2
number_matrix=$3
output="matrix_reload.dat"

if [ -f "$output" ]
then
    rm $output
fi

echo "nro matrices: $number_matrix"

for i in `seq $number_matrix`
do
    line=""
    rows=`shuf -i $min-$max -n 1`
    cols=`shuf -i $min-$max -n 1`

	total=$(($cols * $rows))

    line="${rows}x${cols}"

    for c in `seq $total`
    do
		number=`shuf -i 0-100 -n 1`
		line="$line $number "
    done

line="${line}"
echo $line >> $output


#Para que si el primero es de la forma AxB el segundo sea BxC
    line=""
    rows="$cols"
    cols=`shuf -i $min-$max -n 1`
    

    total=$(($cols * $rows))

    line="${rows}x${cols}"

    for c in `seq $total`
    do
        number=`shuf -i 0-100 -n 1`
        line="$line $number "
    done

    line="${line}"
    echo $line >> $output


done



