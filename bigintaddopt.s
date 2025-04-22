//----------------------------------------------------------------------
// bigintaddopt.s                                                        
// Author: James Swinehart and Benny Wertheimer                       
//----------------------------------------------------------------------
        .section .text

        //--------------------------------------------------------------
        // Return the larger of lLength1 and lLength2.
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    LARGER_STACK_BYTECOUNT, 32

        // Local variable registers
        LLARGER    .req x21 
        
        // Parameter registers
        LLENGTHTWO .req x20
        LLENGTHONE .req x19

BigInt_larger:

        // Prologue
        sub     sp, sp, LARGER_STACK_BYTECOUNT
        str     x30, [sp]
        str     x19, [sp, 8]
        str     x20, [sp, 16]
        str     x21, [sp, 24]

        // Store parameters in registers
        mov     LLENGTHONE, x0
        mov     LLENGTHTWO, x1

        // long lLarger

        // if (lLength1 <= lLength2) goto elseTwoLarger
        cmp     LLENGTHONE, LLENGTHTWO
        bls     elseTwoLarger

        // lLarger = lLength1;
        mov     LLARGER, LLENGTHONE

        // goto endifOneLarger
        b       endifOneLarger

elseTwoLarger:

        // lLarger = lLength2;
        mov     LLARGER, LLENGTHTWO

endifOneLarger:

        // Epilogue and return lLarger
        mov     x0, LLARGER
        ldr     x19, [sp, 8]
        ldr     x20, [sp, 16]
        ldr     x21, [sp, 24]
        add     sp, sp, LARGER_STACK_BYTECOUNT
        ret

        .size   BigInt_larger, (. - BigInt_larger)

        //--------------------------------------------------------------
        // Assign the sum of oAddend1 and oAddend2 to oSum.  oSum should
        // be distinct from oAddend1 and oAddend2.  Return 0 (FALSE) if 
        // an overflow occurred, and 1 (TRUE) otherwise.
        //--------------------------------------------------------------
        
        // Must be a multiple of 16
        .equ    ADD_STACK_BYTECOUNT, 80

        // BigInt constant
        .equ    MAX_DIGITS, 32768

        // Booleans
        .equ    FALSE, 0
        .equ    TRUE, 1

        // Structure field offset
        .equ    LLENGTH, 0
        .equ    AULDIGITS, 8

        // Local variables stack offsets
        ULCARRY    .req x25
        ULSUM      .req x24
        LINDEX     .req x23
        LSUMLENGTH .req x22

        // Parameter stack offsets
        OSUM       .req x21
        OADDENDTWO .req x20
        OADDENDONE .req x19

        .global BigInt_add

BigInt_add:

        // Prologue
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]
        str     x19, [sp, 16]
        str     x20, [sp, 24]
        str     x21, [sp, 32]
        str     x22, [sp, 40]
        str     x23, [sp, 48]
        str     x24, [sp, 56]
        str     x25, [sp, 64]

        // Store parameters in registers
        mov     OADDENDONE, x0
        mov     OADDENDTWO, x1
        mov     OSUM, x2

        // unsigned long ulCarry;
        // unsigned long ulSum;
        // long lIndex;
        // long lSumLength;

        // lSumLength = BigInt_larger(oAddend1->lLength, 
        //                            oAddend2->lLength);
        ldr     x0, [OADDENDONE, LLENGTH]
        ldr     x1, [OADDENDTWO, LLENGTH]
        bl      BigInt_larger
        mov     LSUMLENGTH, x0

        // if (oSum->lLength <= lSumLength) goto endifOSumLarger
        ldr     x0, [OSUM, LLENGTH]
        cmp     x0, LSUMLENGTH
        bls     endifOSumLarger

        // memset(oSum->aulDigits, 0, 
        //        MAX_DIGITS * sizeof(unsigned long));
        add     x0, OSUM, AULDIGITS
        mov     x1, 0
        mov     x2, MAX_DIGITS
        lsl     x2, x2, 3
        bl      memset

endifOSumLarger:

        // ulCarry = 0;
        mov     ULCARRY, 0

        // lIndex = 0
        mov     LINDEX, 0

additionLoop:

        // if (lIndex >= lSumLength) goto endAdditionLoop;
        cmp     LINDEX, LSUMLENGTH
        bhs     endAdditionLoop

        // ulSum = ulCarry;
        mov     ULSUM, ULCARRY

        // ulCarry = 0;
        mov     ULCARRY, 0

        // ulSum += oAddend1->aulDigits[lIndex];
        add     x1, OADDENDONE, AULDIGITS
        lsl     x2, LINDEX, 3
        add     x1, x1, x2
        ldr     x2, [x1]
        add     ULSUM, ULSUM, x2

        // if (ulSum >= oAddend1->aulDigits[lIndex]) 
        // goto endifOneOverflow;
        add     x1, OADDENDONE, AULDIGITS
        lsl     x2, LINDEX, 3
        add     x1, x1, x2
        ldr     x2, [x1]
        cmp     ULSUM, x2
        bhs     endifOneOverflow

        // ulCarry = 1;
        mov     ULCARRY, 1

endifOneOverflow:

        // ulSum += oAddend2->aulDigits[lIndex];
        add     x1, OADDENDTWO, AULDIGITS
        lsl     x2, LINDEX, 3
        add     x1, x1, x2
        ldr     x2, [x1]
        add     ULSUM, ULSUM, x2

        // if (ulSum >= oAddend2->aulDigits[lIndex]) 
        // goto endifTwoOverflow;
        add     x1, OADDENDTWO, AULDIGITS
        lsl     x2, LINDEX, 3
        add     x1, x1, x2
        ldr     x2, [x1]
        cmp     ULSUM, x2
        bhs     endifTwoOverflow

        // ulCarry = 1;
        mov     ULCARRY, 1

endifTwoOverflow:

        // oSum->aulDigits[lIndex] = ulSum;
        add     x1, OSUM, AULDIGITS
        lsl     x2, LINDEX, 3
        add     x1, x1, x2
        str     ULSUM, [x1]

        // lIndex++;
        add     LINDEX, LINDEX, 1

        // goto additionLoop;
        b       additionLoop

endAdditionLoop:

        // if (ulCarry != 1) goto endifCarryIsOne;
        cmp     ULCARRY, 1
        bne     endifCarryIsOne

        // if (lSumLength != MAX_DIGITS) goto endifSumIsMaxDigits;
        cmp     LSUMLENGTH, MAX_DIGITS
        bne     endifSumIsMaxDigits

        // return FALSE;
        mov     w0, FALSE
        ldr     x19, [sp, 16]
        ldr     x20, [sp, 24]
        ldr     x21, [sp, 32]
        ldr     x22, [sp, 40]
        ldr     x23, [sp, 48]
        ldr     x24, [sp, 56]
        ldr     x25, [sp, 64]
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

endifSumIsMaxDigits:

        // oSum->aulDigits[lSumLength] = 1;
        mov     x1, OSUM
        add     x1, x1, AULDIGITS
        mov     x2, LSUMLENGTH
        lsl     x2, x2, 3
        add     x1, x1, x2
        mov     x2, 1
        str     x2, [x1]

        // lSumLength++;
        add     LSUMLENGTH, LSUMLENGTH, 1

endifCarryIsOne:

        // oSum->lLength = lSumLength;
        str     LSUMLENGTH, [OSUM, LLENGTH]

        // Epilogue and return TRUE;
        mov     w0, TRUE
        ldr     x19, [sp, 16]
        ldr     x20, [sp, 24]
        ldr     x21, [sp, 32]
        ldr     x22, [sp, 40]
        ldr     x23, [sp, 48]
        ldr     x24, [sp, 56]
        ldr     x25, [sp, 64]
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)
