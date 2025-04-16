#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define TOTAL_DIGITS 40000
#define LINE_LENGTH 72

int main(void) {
    int i;
    srand((unsigned) time(NULL));

    for (i = 0; i < TOTAL_DIGITS; i++) {
        int bit = rand() % 2;
        putchar(bit ? '1' : '0');  

        if ((i + 1) % LINE_LENGTH == 0) {
            putchar('\n');
        }
    }

    if (TOTAL_DIGITS % LINE_LENGTH != 0) {
        putchar('\n');
    }

    return 0;
}