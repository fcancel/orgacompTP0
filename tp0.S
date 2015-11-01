#void multiplyMatrices(int secondRow, int secondColumn, double * firstValues, double * secondValues, double * multipliedMatrix, int firstRow, int firstColumn);

#include <mips/regdef.h>
#include <sys/syscall.h>

###FUNCION EQUIVALENTE EN C

#void multiplyMatrices(int secondRow, int secondColumn, double * firstValues, double * secondValues, double * multipliedMatrix, int firstRow, int firstColumn){
#                //multiply matrices
#        int firstOffset = 0;
#        int secondOffset = 0;
#        int totCol = 0;
#        int totRow = 0;
#        double partialResult = 0.0f;
#        int contadorcito = 0;
#        
#        for ( totRow = 0; totRow < firstRow * firstColumn; ) {
#                for ( totCol = 0; totCol < secondColumn; ) {
#                        while ( secondOffset <= (secondRow * secondColumn - 1) ) {
#                                multipliedMatrix[contadorcito] += firstValues[firstOffset] * secondValues[secondOffset];
#                                firstOffset++;
#                                secondOffset += secondColumn;
#                        }
#                        contadorcito+;
#                        partialResult = 0.0f;
#                        totCol++;
#                        firstOffset = totRow;
#                        secondOffset = totCol;
#                }
#                totRow += firstColumn;
#                firstOffset = totRow;
#                secondOffset = 0;
#        }
#}

        .text
        .globl multiplyMatrices
multiplyMatrices:
        #Antes que nada, como me vienen 6 variables, voy a guardar en variables temporales
        #Las dos variables que me van a quedar afuera, que son los dos punteros
        # firstValues y secondValues
        lw      t1, 16(sp)       #Guardo en t1 el valor del puntero de multipliedMatriz
        lw      t2, 20(sp)       #Guardo en t2 el valor de firstRow
        lw      t3, 24(sp)       #Guardo en t3 el valor de firstColumn

        .set    noreorder
        .cpload $25
        .set    reorder

        #Voy a necesitar espacio para 4 variables int y una double
        subu    sp, sp, 64       #Reservo X slots de 64 bits
        
        .cprestore 40            #En el 24 voy a poner mi gp
        
        sw      gp, 52(sp)       #Guardo mi stack pointer
        sw      $fp, 56(sp)      #Guardo mi return address
        sw      ra, 60(sp)       #Guardo mi frame pointer
        move    $fp, sp          #Ahora debería trabajar con mi frame pointer en vez de stack pointer

        move    t0, zero        #Va a tener el valor 0 a0
        sw      t0, 0($fp)       #En 0(sp) tengo int firstOffset = 0
        sw      t0, 4($fp)       #En 4(sp) tengo int secondOffset = 0
        sw      a0, 8($fp)       #En 8(sp) tengo int secondRow
        sw      a1, 12($fp)      #En 12(sp) tengo int secondColumn
        sw      a2, 16($fp)      #En 16(sp) tengo el puntero firstValues
        sw      a3, 20($fp)      #En 20(sp) tengo el puntero secondValues
        sw      t0, 24($fp)      #En 24(sp) tengo int totCol = 0
        sw      t0, 28($fp)      #En 28(sp) tengo int totRow = 0
        sw      t1, 32($fp)      #En 32(sp) tengo el puntero multipliedMatriz
        sw      t2, 36($fp)      #En 36(sp) tengo el valor de firstRow
        sw      t3, 40($fp)      #En 40(sp) tengo el valor de firstColumn
        sw      t0, 44($fp)      #En 44(sp) tengo un contadorcito = 0

        li.d    $f0, 0.0

primerFor:
#       for ( totRow = 0; totRow < firstRow * firstColumn; )
        #Cargo todo de nuevo
        lw      t0, 28($fp)     #En t0 tengo totRow
        lw      t1, 36($fp)     #En t1 tengo firstRow
        lw      t2, 40($fp)     #En t2 tengo firstColumn

        mulo    t3, t1, t2      #En t3 tengo firstRow * firstColumn

        bge     t0, t3, retornar        #Si totRow no es menor a firstRow * firstColumn, termine
        b       segundoFor      #Si no retorno segui al segundo for

segundoFor:
#        for ( totCol = 0; totCol < secondColumn; )
        #Cargo todo de nuevo
        lw      t0, 24($fp)     #En t0 tengo totCol
        lw      t1, 12($fp)     #En t1 tengo secondColumn

        bge     t0,t1, finSegundoFor    #Anda al fin del segundo for
        b       unicoWhile      #Sino segui para unicowhile

unicoWhile:
#       while ( secondOffset <= (secondRow * secondColumn - 1) )
        #Como siempre, conviene cargar todo de nuevo
        lw      t0, 4($fp)       #cargo en t0 secondOffset
        lw      t1, 8($fp)       #cargo en t1 secondRow 
        lw      t2, 12($fp)      #cargo en t2 secondColumn
        mulo    t3, t1, t2      #Multiplico con overflow secondRow * secondColumn y lo guardo en t3
        addi    t4, t3, -1      #Le resto uno a lo anterior y lo guardo en t4

        bgt     t0, t4, segundoForContinuado    #Si secondOffset es mas grande, me voy
        b       multiplicacion  #Sino segui hacia la multiplicacion


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

segundoForContinuado:
#       Aca voy a tener que guardar el valor en multipliedMatrix y totCol++; f = totRow;  s = totCol;
        lw      t3, 44($fp)     #En t3 tengo el contadorcito
        sll     t3, t3, 3       #Multiplico por 8 para que el offset me de de a 64
        lw      t4, 32($fp)     #En t4 tengo el puntero a multipliedMatriz
        add     t4, t3, t4      #En t4 guardo el puntero mas el offset para guardar en el el valor de la cuenta
        s.d     $f0, 0(t4)      #Guarde el valor en multipliedMatriz[contadorcito]
        lw      t3, 44($fp)     #Cargo el contador nuevamente
        addi    t3, t3, 1       #Le sumo uno al contador
        sw      t3, 44($fp)     #Guardo el valor en el contador
        li.d    $f0, 0.0        #Hago que valga cero de nuevo

        lw      t0, 24($fp)     #En t0 tengo totCol
        addi    t0, t0, 1       #Le totCol++
        sw      t0, 24($fp)     #Guardo su valor

        lw      t1, 28($fp)     #En t1 meto totRow
        sw      t1, 0($fp)      #En firstOffset guardo el valor de totRow
        lw      t2, 24($fp)     #En t2 meto totCol
        sw      t2, 4($fp)      #En secondOffset meto el valor de totCol

        b       segundoFor      #Vuelvo al segundo for

finSegundoFor:
#       totRow += firstColumn; f = totRow; s = 0;
        #Cargo todo de nuevo
        lw      t0, 28($fp)     #Cargo en t0 totRow
        lw      t1, 40($fp)     #Cargo en t1, firstColumn
        add     t0, t0, t1      #Hago la suma totRow + firstColumn
        sw      t0, 28($fp)     #Guardo el valor de la suma en totRow
        sw      t0, 0($fp)      #Guardo el valor totRow en firstOffset
        move    t2, zero       #Hago que t2 tenga el valor 0
        sw      t2, 4($fp)      #Guardo el valor cero en secondOffset

        move    t0, zero
        sw      t0, 24($fp)     #Hago que totCol vuelva a valer cero
        b       primerFor       #Voy al primer for
        

retornar:
        #Y acá habría terminado
        lw      gp, 52(sp)
        lw      $fp, 56(sp)
        lw      ra, 60(sp)
        addu    sp, sp, 64
        j       ra              #Salto y me voy de la función retorno el $f0-$f1
