#include <mips/regdef.h>

        .text
        .globl MIPSfunction
MIPSfunction:
        sll     a1, a1, 3       #Lo multiplico por ocho al offset del primero
        sll     a3, a3, 3       #Lo multiplico por ocho al offset del segundo
        add     a0, a0, a1      #Le agrego el offset a mi array primero
        add     a2, a2, a3      #Le agrego mi offset a mi array segundo
        l.d     $f2,0(a0)       #Cargo su valor en f2
        l.d     $f4,0(a2)       #Cargo su valor en f4
        mul.d   $f0,$f2,$f4     #Realizo la multiplicacion
        j       ra
