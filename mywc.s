//----------------------------------------------------------------------
// mywc.s
// Author: James Swinehart and Benny Wertheimer
//----------------------------------------------------------------------

        .section .rodata

printfFormatStr:
        .string "%7ld %7ld %7ld\n"

//----------------------------------------------------------------------

        .section .data

lLineCount:
        .quad   0

lWordCount:
        .quad   0

lCharCount:
        .quad   0

iInWord:
        .word   0

//----------------------------------------------------------------------

        .section .bss

iChar:
        .skip   4


//----------------------------------------------------------------------

        .section .text

        //--------------------------------------------------------------
        // Write to stdout counts of how many lines, words, and 
        // characters are in stdin. A word is a sequence of 
        // non-whitespace characters. Whitespace is defined by the 
        // isspace() function. Return 0.
        //--------------------------------------------------------------

        // Must be a multiple of 16
        .equ    MAIN_STACK_BYTECOUNT, 16

        .global main

main:
        
        // Prologue
        sub     sp, sp, MAIN_STACK_BYTECOUNT
        str     x30, [sp]

mainLoop:

        // if ((iChar = getchar()) == EOF) goto endMainLoop;      
        bl      getchar
        adr     x1, iChar 
        str     w0, [x1]
        cmp     w0, -1
        beq     endMainLoop

        // lCharCount++;
        adr     x0, lCharCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

        // if (! isspace(iChar)) goto elseNotSpace;
        adr     x0, iChar
        ldr     w0, [x0]
        bl      isspace
        cmp     w0, 0
        beq     elseNotSpace

        // if (! iInWord) goto endifWord;
        adr     x0, iInWord
        ldr     w0, [x0]
        cmp     w0, 0
        beq     endifWord

        // lWordCount++;
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

        // iInWord = FALSE;
        adr     x0, iInWord
        mov     w0, 0
        str     w0, [x0]

endifWord:
elseNotSpace:

        // if (iInWord) goto endifNotInWord;
        adr     x0, iInWord
        ldr     w0, [x0]
        cmp     w0, 0
        bne     endifNotInWord

        // iInWord = TRUE;
        adr     x0, iInWord
        mov     w0, 1
        str     w0, [x0]

endifNotInWord:
endifSpace:

        // if (iChar != '\n') goto endifNewline;
        adr     x0, iChar
        ldr     w0, [x0]
        cmp     w0, 10
        bne     endifNewline

        // lLineCount++;
        adr     x0, lLineCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

endifNewline:

        // goto mainLoop
        b       mainLoop

endMainLoop:

        // if (! iInWord) goto endifLastWord;
        adr     x0, iInWord
        ldr     w0, [x0]
        cmp     w0, 0
        beq     endifLastWord

        // lWordCount++;
        adr     x0, lWordCount
        ldr     x1, [x0]
        add     x1, x1, 1
        str     x1, [x0]

endifLastWord:

        // printf("%7ld %7ld %7ld\n",
        //        lLineCount, lWordCount, lCharCount);
        adr     x0, printfFormatStr
        adr     x1, lLineCount
        ldr     x1, [x1]
        adr     x2, lWordCount
        ldr     x2, [x2]
        adr     x3, lCharCount
        ldr     x3, [x3]
        bl      printf
        
        // Epilogue and return 0
        mov     w0, 0
        ldr     x30, [sp]
        add     sp, sp, MAIN_STACK_BYTECOUNT
        ret

        .size   main, (. - main)
