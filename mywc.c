/*--------------------------------------------------------------------*/
/* mywc.c                                                             */
/* Author: Bob Dondero                                                */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <ctype.h>

/*--------------------------------------------------------------------*/

/* In lieu of a boolean data type. */
enum {FALSE, TRUE};

/*--------------------------------------------------------------------*/

static long lLineCount = 0;      /* Bad style. */
static long lWordCount = 0;      /* Bad style. */
static long lCharCount = 0;      /* Bad style. */
static int iChar;                /* Bad style. */
static int iInWord = FALSE;      /* Bad style. */

/*--------------------------------------------------------------------*/

/* Write to stdout counts of how many lines, words, and characters
   are in stdin. A word is a sequence of non-whitespace characters.
   Whitespace is defined by the isspace() function. Return 0. */

int main(void)
{
   /* loop1 */
   while ((iChar = getchar()) != EOF)
   {
      lCharCount++;

      /* if1 */
      if (isspace(iChar))
      {
         /* if2 */
         if (iInWord)
         {
            lWordCount++;
            iInWord = FALSE;
         }
      }
      /* else1 */
      else
      {
         /* if3 */
         if (! iInWord)
            iInWord = TRUE;
      }
      /* if4 */
      if (iChar == '\n')
         lLineCount++;
   }

   /* if5 */
   if (iInWord)
      lWordCount++;

   printf("%7ld %7ld %7ld\n", lLineCount, lWordCount, lCharCount);
   return 0;
}
