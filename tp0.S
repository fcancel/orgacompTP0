#double multiplyMatrices(int firstOffset, int secondOffset, int secondRow, int secondColumn, double * firstValues, double * secondValues);

#include <mips/regdef.h>
#include <sys/syscall.h>

#define SIZE_stringNewline 1
#define SIZE_stringX 1
#define SIZE_stringSpace 1
#define std_out 1

###FUNCION EQUIVALENTE EN C
#void multiplyMatrices (int firstRow, int firstColumn, int secondRow, int secondColumn, double * firstValues, double * secondValues){
#		//multiply matrices
#	int firstOffset = 0;
#	int secondOffset = 0;
#	int totCol = 0;
#	int totRow = 0;
#	double partialResult = 0.0f;
#
#		while ( secondOffset <= (secondRow * secondColumn - 1) ) {
#			partialResult += firstValues[firstOffset] * secondValues[secondOffset];
#			firstOffset++;
#			secondOffset += secondColumn;
#		}
#		printf( " %.2f", partialResult );
#		partialResult = 0.0f;
#		totCol++;
#		firstOffset = totRow;
#		secondOffset = totCol;

        .text
        .globl multiplyMatrices
multiplyMatrices:
        #Antes que nada, como me vienen 6 variables, voy a guardar en variables temporales
        #Las dos variables que me van a quedar afuera, que son los dos punteros
        # firstValues y secondValues
        lw      t4, 16(sp)      #Guardo en t4 el valor del puntero firstValues
        lw      t5, 20(sp)      #Guardo en t5 el valor del puntero secondValues
        
        .frame  $29, 40, $31
        .set    noreorder
        .cpload $25
        .set    reorder

        #Voy a necesitar espacio para 4 variables int y una double
        subu    sp, sp, 40      #Reservo X slots de 64 bits
        
        .cprestore 24           #En el 24 voy a poner mi gp
        
        sw      gp, 24(sp)      #Guardo mi stack pointer
        sw      $fp, 28(sp)      #Guardo mi return address
        sw      ra, 32(sp)      #Guardo mi frame pointer
        move    $fp, sp          #Ahora debería trabajar con mi frame pointer en vez de stack pointer

        sw      a0, 0($fp)       #En 0(sp) tengo int firstOffset
        sw      a1, 4($fp)       #En 4(sp) tengo int secondOffset
        sw      a2, 8($fp)       #En 8(sp) tengo int secondRow
        sw      a3, 12($fp)      #En 12(sp) tengo int secondColumn
        sw      t4, 16($fp)      #En 16(sp) tengo el puntero firstValues
        sw      t5, 20($fp)      #En 20(sp) tengo el puntero secondValues

        li.d    $f0, 0.0

unicoWhile:
#       while ( secondOffset <= (secondRow * secondColumn - 1) )
        #Como siempre, conviene cargar todo de nuevo
        lw      t0, 4($fp)       #cargo en t0 secondOffset
        lw      t1, 8($fp)       #cargo en t1 secondRow 
        lw      t2, 12($fp)      #cargo en t2 secondColumn
        mulo    t3, t1, t2      #Multiplico con overflow secondRow * secondColumn y lo guardo en t3
        addi    t4, t3, -1      #Le resto uno a lo anterior y lo guardo en t4

        bgt     t0, t4, retornar    #Si secondOffset es mas grande, me voy


multiplicacion:
#       partialResult += firstValues[firstOffset] * secondValues[secondOffset];
        lw      t0, 16($fp)      #en t0 tengo firstValues
        lw      t1, 20($fp)      #En t1 tengo secondValues
        lw      t2, 0($fp)       #En t2 tengo firstOffset
        lw      t3, 4($fp)       #En t3 tengo secondOffset
#       Como todo está en double, cuando me desplace onda firstValues[1] tengo que ir al primero, y sumarle 64 bits
        sll     t2, t2, 3       #Multiplico por 8 para que me de bien el offset (8*8=64)
        sll     t3, t3, 3       #Multiplico por 8 para que me de bien el offset (8*8=64)
#       Ahora le voy a sumar esos offsets a firstValues y secondValues
        add     t0, t0, t2      #Hice firstValues[firstOffset]
        add     t1, t1, t3      #Hice secondValues[secondOffset]
        l.d     $f12, 0(t0)      # f12 a f13 van a tener el valor del double firstValues[firstOffset] en f0
        l.d     $f14, 0(t1)      # f14 a f15 van a tener el valor del double secondValues[secondOffset] en f2
        mul.d   $f2, $f12, $f14   # f0 a f1 van a tener el valor de su multiplicacion o sea partialResult
        add.d   $f0, $f0, $f2
#       firstOffset++;
        lw      t0, 0($fp)       #meto en t0 firstOffset
        addi    t1, t0, 1       #Le sumo 1
        sw      t1, 0($fp)       #y lo guardo
#       secondOffset += secondColumn;
        lw      t0, 4($fp)       #cargo en t0 secondOffset
        lw      t1, 12($fp)      #cargo en t1 secondColumn
        add     t3, t0, t1      #secondOffset += secondColumn
        sw      t3, 4($fp)       #guardo el valor

        b       unicoWhile      #termino y vuelvo al unico while

retornar:
        #Y acá habría terminado
        lw      gp, 24(sp)
        lw      $fp, 28(sp)
        lw      ra, 32(sp)
        addu    sp, sp, 32
        j       ra              #Salto y me voy de la función retorno el $f0-$f1
