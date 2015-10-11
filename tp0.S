#void multiplyMatrices(int firstRow, int firstColumn, int secondRow, int secondColumn, double * firstValues, double * secondValues);

#include <mips/regdef.h>

        .text
        .globl MIPSfunction
MIPSfunction:
        #Antes que nada, como me vienen 6 variables, voy a guardar en variables temporales
        #Las dos variables que me van a quedar afuera, que son los dos punteros
        # firstValues y secondValues
        lw      t0, 16(sp)      #Guardo en t0 el valor del puntero firstValues
        lw      t1, 20(sp)      #Guardo en t1 el valor del puntero secondValues

        #Voy a necesitar espacio para 4 variables int y una double
        subu    sp, sp, 68      #Reservo X slots de 32 bits
        li      t0, 0           #Acá inicio mivariable firstOffset
        sw      t0, 0(sp)       #En 0(sp) tengo int firstOffset = 0
        sw      t0, 4(sp)       #En 4(sp) tengo int secondOffset = 0
        sw      t0, 8(sp)       #En 8(sp) tengo int totCol = 0
        sw      t0, 12(sp)      #En 12(sp) tengo int totRow = 0
        sw      a0, 16(sp)      #En 16(sp) tengo firstRow que viene de afuera
        sw      a1, 20(sp)      #En 20(sp) tengo firstColumn que viene de afuera
        sw      a2, 24(sp)      #En 24(sp) tengo secondRow que viene de afuera
        sw      a3, 28(sp)      #En 28(sp) tengo secondColumn que viene de afuera
        sw      t0, 32(sp)      #En 32(sp) tengo el puntero firstValues
        sw      t1, 36(sp)      #En 36(sp) tengo el puntero secondValues

primerPrint:
#       printf("%dx%d", firstRow, secondColumn);
        li      v0, 1           #El 1 es el codigo para hacer un print int
        la      a0, 16(sp)      #Meto en a0 el valor de firstRow
        syscall                 #Va a printear el valor de a0, que en este caso es firstRow
        li      v0, 4           #El 4 es el codigo para hacer un print string
        la      a0, stringX     #Load address of string to be printed into $a0
        syscall                 #Va a printear el valor de a0, que en este caso es 'x'
        li      v0,1            #El 1 es el codigo para hacer un print int
        la      a0, 28(sp)      #Meto en a0 el valor de secondColumn
        syscall                 #Va a printear el valor de a0, que en este caso es secondColumn


#Se viene el primer for
#      for ( totRow = 0; totRow < firstRow * firstColumn; ) 
        #Como siempre, me conviene cargar todo por si las dudas
primerFor:
        lw      t0, 12(sp)      #tengo en t0 totRow
        lw      t1, 16(sp)      #tengo en t1 firstRow
        lw      t2, 20(sp)      #tengo en t2 firstColumn
        mulo    t3, t1, t2      #Multiplico con overflow t1*t2 y el valor lo guardo en t3

        bge     t0, t3, lastPrint       #Si totRow < firstRow * firstColumn me voy

#       pero si no pasa eso voy al:
segundoFor:
#       for ( totCol = 0; totCol < secondColumn; )
        #Como siempre, conviene cargar todo de nuevo
        lw      t0, 8(sp)       #tengo en t0 totCol
        lw      t1, 28(sp)      #tengo en t1 secondColumn

        bge     t0,t1, outOfSecondFor   #si totCol < secondColumn me voy

unicoWhile:
#       while ( secondOffset <= (secondRow * secondColumn - 1) )
        #Como siempre, conviene cargar todo de nuevo
        lw      t0, 4(sp)       #cargo en t0 secondOffset
        lw      t1, 24(sp)      #cargo en t1 secondRow 
        lw      t2, 28(sp)      #cargo en t2 secondColumn
        mulo    t3, t1, t2      #Multiplico con overflow secondRow * secondColumn y lo guardo en t3
        addi    t4, t3, -1      #Le resto uno a lo anterior y lo guardo en t4

        bgt     t0, t4, segundoPrint    #Si secondOffset es mas grande, me voy


multiplicacion:
#       partialResult += firstValues[firstOffset] * secondValues[secondOffset];
        lw      t0, 32(sp)      #en t0 tengo firstvalues
        lw      t1, 36(sp)      #En t1 tengo secondValues
        lw      t2, 0(sp)       #En t2 tengo firstOffset
        lw      t3, 4(sp)       #En t3 tengo secondOffset
#       Como todo está en double, cuando me desplace onda firstValues[1] tengo que ir al primero, y sumarle 64 bits
        sll     t2, t2, 3       #Multiplico por 8 para que me de bien el offset (8*8=64)
        sll     t3, t3, 3       #Multiplico por 8 para que me de bien el offset (8*8=64)
#       Ahora le voy a sumar esos offsets a firstValues y secondValues
        add     t0, t0, t2      #Hice firstValues[firstOffset]
        add     t1, t1, t3      #Hice secondValues[secondOffset]
        l.d     $f0, 0(t0)      # f0 a f1 van a tener el valor del double firstValues[firstOffset] en f0
        l.d     $f2, 0(t1)      # f2 a f3 van a tener el valor del double secondValues[secondOffset] en f2
        mul.d   $f12. $f0, $f2   # f12 a f13 van a tener el valor de su multiplicacion o sea partialResult

#       firstOffset++;
        lw      t0, 0(sp)       #meto en t0 firstOffset
        addi    t1, t0, 1       #Le sumo 1
        sw      t1, 0(sp)       #y lo guardo
#       secondOffset += secondColumn;
        lw      t0, 4(sp)       #cargo en t0 secondOffset
        lw      t1, 28(sp)      #cargo en t1 secondColumn
        add     t3, t0, t1      #secondOffset += secondColumn
        sw      t3, 4(sp)       #guardo el valor

        b       unicoWhile      #termino y vuelvo al unico while

segundoPrint:
#       printf( " %.2f", partialResult );
        li      v0, 4                   #El 4 es el codigo para hacer un print string
        la      a0, stringSpace         #Load address of string to be printed into $a0
        syscall                         #Va a printear el valor de a0, que en este caso es ' '
        li      v0, 3                   #El 3 es el codigo para hacer un print double
        syscall                         #Supongo que aca no se modifico $f12 y tengo el valor deseado
#       partialResult = 0.0f;

        li.d    $f12,0.0                #No se si esa instruccion funciona o va bien
        
#       totCol++;
        lw      t0, 8(sp)               #cargo en t0 totCol
        addi    t1, t0, 1               #t1 tiene totCol +1
        sw      t1, 8(sp)               #guardo el valor
#       firstOffset = totRow;
        lw      t0, 12(sp)              #En t0 totRow
        sw      t0, 0(sp)               #firstOffset = totRow
#       secondOffset = totCol;
        lw      t0, 8(sp)               #cargo en t0 totCol
        sw      t0, 4(sp)               #secondOffset = totCol

        b       segundoFor              #Vuelvo al segundo for


outOfSecondFor:
#totRow += firstColumn;
        lw      t0, 12(sp)      #t0 tiene a totRow
        lw      t1, 20(sp)      #t1 tiene a firstColumn
        add     t0, t0, t1      #meto en t0 totRow + firstColumn
        sw      t0, 12(sp)      #guardo su valor        
#firstOffset = totRow;
        lw      t0, 12(sp)      #t0 tiene a totRow
        sw      t0, 0(sp)       #guardo en firstOffset el valor de totRow
#secondOffset = 0;
        li      t0, 0           #t0 tiene el valor 0
        sw      t0, 4(sp)       #guardo el valor de t0 en secondOffset

        b       primerFor       #Vuelvo al primer for


lastPrint:
        li      v0, 4           #El 4 es el codigo para hacer un print string
        la      a0, stringX     #Load address of string to be printed into $a0
        syscall                 #Va a printear el valor de a0, que en este caso es "\n"
        #Y acá habría terminado
        j       ra              #Salto y me voy de la función

        .data
stringX         .asciiz "x"
stringNewline   .asciiz "\n"
stringSpace     .asciiz " "
