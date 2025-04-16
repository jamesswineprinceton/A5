#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define RAND_STRING_LENGTH 40000

char* generateRandomString(void) {
    const char allowed[] = "\n !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";
    size_t allowedCount = sizeof(allowed) - 1; 

    char *str = malloc(RAND_STRING_LENGTH + 1);
    if (str == NULL) {
        return NULL;
    }

    {
        size_t i;  /* Declare variable outside the for loop */
        for (i = 0; i < RAND_STRING_LENGTH; i++) {
            str[i] = allowed[rand() % allowedCount];
        }
    }

    str[RAND_STRING_LENGTH] = '\0';
    return str;
}

int main(void) {
    char *randomStr;  /* Moved declaration to the beginning of the block */
    
    srand((unsigned)time(NULL));

    randomStr = generateRandomString();
    if (randomStr == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return EXIT_FAILURE;
    }

    printf("%s\n", randomStr);

    free(randomStr);
    return EXIT_SUCCESS;
}