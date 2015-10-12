#double multiplyMatrices(int firstOffset, int secondOffset, int secondRow, int secondColumn, double * firstValues, double * secondValues);

#include <mips/regdef.h>
#include <sys/syscall.h>

#define SIZE_stringNewline 1
#define SIZE_stringX 1
#define SIZE_stringSpace 1
#define std_out 1

        .text
        .globl multiplyMatrices
multiplyMatrices:
        #Antes que nada, como me vienen 6 variables, voy a guardar en variables temporales
        #Las dos variables que me van a quedar afuera, que son los dos punteros
        # firstValues y secondValues
        lw      t4, 16(sp)      #Guardo en t4 el valor del puntero firstValues
        lw      t5, 20(sp)      #Guardo en t5 el valor del puntero secondValues

        #Voy a necesitar espacio para 4 variables int y una double
        subu    sp, sp, 32      #Reservo X slots de 64 bits
        sw      a0, 0(sp)       #En 0(sp) tengo int firstOffset
        sw      a1, 4(sp)       #En 4(sp) tengo int secondOffset
        sw      a2, 8(sp)       #En 8(sp) tengo int secondRow
        sw      a3, 12(sp)      #En 12(sp) tengo int secondColumn
        sw      t4, 16(sp)      #En 16(sp) tengo el puntero firstValues
        sw      t5, 20(sp)      #En 20(sp) tengo el puntero secondValues

        li.d    $f0, 0.0

unicoWhile:
#       while ( secondOffset <= (secondRow * secondColumn - 1) )
        #Como siempre, conviene cargar todo de nuevo
        lw      t0, 4(sp)       #cargo en t0 secondOffset
        lw      t1, 8(sp)       #cargo en t1 secondRow 
        lw      t2, 12(sp)      #cargo en t2 secondColumn
        mulo    t3, t1, t2      #Multiplico con overflow secondRow * secondColumn y lo guardo en t3
        addi    t4, t3, -1      #Le resto uno a lo anterior y lo guardo en t4

        bgt     t0, t4, retornar    #Si secondOffset es mas grande, me voy


multiplicacion:
#       partialResult += firstValues[firstOffset] * secondValues[secondOffset];
        lw      t0, 16(sp)      #en t0 tengo firstValues
        lw      t1, 20(sp)      #En t1 tengo secondValues
        lw      t2, 0(sp)       #En t2 tengo firstOffset
        lw      t3, 4(sp)       #En t3 tengo secondOffset
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
        lw      t0, 0(sp)       #meto en t0 firstOffset
        addi    t1, t0, 1       #Le sumo 1
        sw      t1, 0(sp)       #y lo guardo
#       secondOffset += secondColumn;
        lw      t0, 4(sp)       #cargo en t0 secondOffset
        lw      t1, 12(sp)      #cargo en t1 secondColumn
        add     t3, t0, t1      #secondOffset += secondColumn
        sw      t3, 4(sp)       #guardo el valor

        b       unicoWhile      #termino y vuelvo al unico while

retornar:
        #Y acá habría terminado
        addu    sp, sp, 32
        j       ra              #Salto y me voy de la función retorno el $f0-$f1
