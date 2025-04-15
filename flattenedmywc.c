/*--------------------------------------------------------------------*/
/* myflattenedwc.c                                                    */
/* Author: James Swinehart and Benny Wertheimer                       */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>

/*--------------------------------------------------------------------*/

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

static long lLineCount = 0;
static long lWordCount = 0;
static long lCharCount = 0;
static int iChar;          
static int iInWord = FALSE;

/*--------------------------------------------------------------------*/

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */

int main(void) {
mainLoop:
    if ((iChar = getchar()) == EOF) goto endMainLoop;
            lCharCount++;
            if (! isspace(iChar)) goto elseNotSpace;
                if (! iInWord) goto endifWord;
                lWordCount++;
                iInWord = FALSE;
            endifWord:
        goto endifSpace;
        elseNotSpace:
                if (iInWord) goto endifNotInWord;
                iInWord = TRUE;
            endifNotInWord:
        endifSpace:
        if (iChar != '\n') goto endifNewline;
        lLineCount++;
    endifNewline:
endMainLoop:
    if (! iInWord) goto endifLastWord;
    lWordCount++;
endifLastWord:
printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
return 0;
}
