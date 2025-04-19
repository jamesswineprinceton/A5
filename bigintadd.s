//----------------------------------------------------------------------
// bigintadd.s                                                        
// Author: James Swinehart and Benny Wertheimer                       
//----------------------------------------------------------------------
        .section .text

        //--------------------------------------------------------------
        // Return the larger of lLength1 and lLength2.
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    LARGER_STACK_BYTECOUNT, 32

        // Local variable stack offsets
        .equ    LLARGER, 8
        
        // Parameter stack offsets
        .equ    LLENGTHONE, 16
        .equ    LLENGTHTWO, 24

BigInt_larger:

        // Prologue
        sub     sp, sp, LARGER_STACK_BYTECOUNT
        str     x30, [sp]
        str     x0, [sp, LLENGTHONE]
        str     x1, [sp, LLENGTHTWO]

        // long lLarger

        // if (lLength1 <= lLength2) goto elseTwoLarger
        ldr     x0, [sp, LLENGTHONE]
        ldr     x1, [sp, LLENGTHTWO]
        cmp     x0, x1
        ble     elseTwoLarger

        // lLarger = lLength1;
        ldr     x0, [sp, LLENGTHONE]
        str     x0, [sp, LLARGER]

        // goto endifOneLarger
        b       endifOneLarger

elseTwoLarger:

        // lLarger = lLength2;
        ldr     x0, [sp, LLENGTHTWO]
        str     x0, [sp, LLARGER]

endifOneLarger:

        // Epilogue and return lLarger
        ldr     x0, [sp, LLARGER]
        ldr     x30, [sp]
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
        .equ    ULCARRY, 16
        .equ    ULSUM, 24
        .equ    LINDEX, 32
        .equ    LSUMLENGTH, 40

        // Parameter stack offsets
        .equ    OADDENDONE, 48
        .equ    OADDENDTWO, 56
        .equ    OSUM, 64

        .global BigInt_add

BigInt_add:

        // Prologue
        sub     sp, sp, ADD_STACK_BYTECOUNT
        str     x30, [sp]
        str     x0, [sp, OADDENDONE]
        str     x1, [sp, OADDENDTWO]
        str     x2, [sp, OSUM]

        // unsigned long ulCarry;
        // unsigned long ulSum;
        // long lIndex;
        // long lSumLength;

        // lSumLength = BigInt_larger(oAddend1->lLength, 
        //                            oAddend2->lLength);
        ldr     x0, [sp, OADDENDONE]
        ldr     x0, [x0, LLENGTH]
        ldr     x1, [sp, OADDENDTWO]
        ldr     x1, [x1, LLENGTH]
        bl      BigInt_larger
        str     x0, [sp, LSUMLENGTH]

        // if (oSum->lLength <= lSumLength) goto endifOSumLarger
        ldr     x0, [sp, OSUM]
        ldr     x0, [x0, LLENGTH]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0, x1
        ble     endifOSumLarger

        // memset(oSum->aulDigits, 0, 
        //        MAX_DIGITS * sizeof(unsigned long));
        ldr     x0, [sp, OSUM]
        add     x0, x0, AULDIGITS
        mov     x1, 0
        mov     x2, MAX_DIGITS
        lsl     x2, x2, 3
        bl      memset

endifOSumLarger:

        // ulCarry = 0;
        mov     x1, 0
        str     x1, [sp, ULCARRY]

        // lIndex = 0
        mov     x1, 0
        str     x1, [sp, LINDEX]

additionLoop:

        // if (lIndex >= lSumLength) goto endAdditionLoop;
        ldr     x0, [sp, LINDEX]
        ldr     x1, [sp, LSUMLENGTH]
        cmp     x0, x1
        bge     endAdditionLoop

        // ulSum = ulCarry;
        ldr     x0, [sp, ULCARRY]
        str     x0, [sp, ULSUM]

        // ulCarry = 0;
        mov     x1, 0
        str     x1, [sp, ULCARRY]

        // ulSum += oAddend1->aulDigits[lIndex];
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OADDENDONE]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        lsl     x2, x2, 3
        add     x1, x1, x2
        ldr     x2, [x1]
        add     x0, x0, x2
        str     x0, [sp, ULSUM]

        // if (ulSum >= oAddend1->aulDigits[lIndex]) 
        // goto endifOneOverflow;
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OADDENDONE]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        lsl     x2, x2, 3
        add     x1, x1, x2
        ldr     x2, [x1]
        cmp     x0, x2
        bge     endifOneOverflow

        // ulCarry = 1;
        mov     x0, 1
        str     x0, [sp, ULCARRY]

endifOneOverflow:

        // ulSum += oAddend2->aulDigits[lIndex];
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OADDENDTWO]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        lsl     x2, x2, 3
        add     x1, x1, x2
        ldr     x2, [x1]
        add     x0, x0, x2
        str     x0, [sp, ULSUM]

        // if (ulSum >= oAddend2->aulDigits[lIndex]) 
        // goto endifTwoOverflow;
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OADDENDTWO]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        lsl     x2, x2, 3
        add     x1, x1, x2
        ldr     x2, [x1]
        cmp     x0, x2
        bge     endifTwoOverflow

        // ulCarry = 1;
        mov     x0, 1
        str     x0, [sp, ULCARRY]

endifTwoOverflow:

        // oSum->aulDigits[lIndex] = ulSum;
        ldr     x0, [sp, ULSUM]
        ldr     x1, [sp, OSUM]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LINDEX]
        lsl     x2, x2, 3
        add     x1, x1, x2
        str     x0, [x1]

        // lIndex++;
        ldr     x0, [sp, LINDEX]
        add     x0, x0, 1
        str     x0, [sp, LINDEX]

        // goto additionLoop;
        b       additionLoop

endAdditionLoop:

        // if (ulCarry != 1) goto endifCarryIsOne;
        ldr     x0, [sp, ULCARRY]
        cmp     x0, 1
        bne     endifCarryIsOne

        // if (lSumLength != MAX_DIGITS) goto endifSumIsMaxDigits;
        ldr     x0, [sp, LSUMLENGTH]
        cmp     x0, MAX_DIGITS
        bne     endifSumIsMaxDigits

        // return FALSE;
        mov      w0, FALSE
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

endifSumIsMaxDigits:

        // oSum->aulDigits[lSumLength] = 1;
        ldr     x1, [sp, OSUM]
        add     x1, x1, AULDIGITS
        ldr     x2, [sp, LSUMLENGTH]
        lsl     x2, x2, 3
        add     x1, x1, x2
        mov     x2, 1
        str     x2, [x1]

        // lSumLength++;
        ldr     x0, [sp, LSUMLENGTH]
        add     x0, x0, 1
        str     x0, [sp, LSUMLENGTH]

endifCarryIsOne:

        // oSum->lLength = lSumLength;
        ldr     x0, [sp, LSUMLENGTH]
        ldr     x1, [sp, OSUM]
        str     x0, [x1, LLENGTH]

        // Epilogue and return TRUE;
        mov     w0, TRUE
        ldr     x30, [sp]
        add     sp, sp, ADD_STACK_BYTECOUNT
        ret

        .size   BigInt_add, (. - BigInt_add)
