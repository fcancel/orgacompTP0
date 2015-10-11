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

#Hago el primer print
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

        #VIEJA FORMA DE MULTIPLICAR
        sll     a1, a1, 3       #Lo multiplico por ocho al offset del primero
        sll     a3, a3, 3       #Lo multiplico por ocho al offset del segundo
        add     a0, a0, a1      #Le agrego el offset a mi array primero
        add     a2, a2, a3      #Le agrego mi offset a mi array segundo
        l.d     $f2,0(a0)       #Cargo su valor en f2
        l.d     $f4,0(a2)       #Cargo su valor en f4
        mul.d   $f0,$f2,$f4     #Realizo la multiplicacion
        #Antes de irnos devolvemos el stack a su valor inicial
        addu    sp, sp, 68      #Tengo que devolverle lo mismo que le saque
        j       ra

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
