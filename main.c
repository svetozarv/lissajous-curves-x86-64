#include <stdio.h>
#include <stdlib.h>
#include "f.h"



int main(int argc, char* argv[]) {
    if (argc < 3) {
        printf("Error: Argument missing.\n");
        printf("Usage: %s <string> <number>\n", argv[0]);
        return 1;
    }

    int n = atoi(argv[2]);
    if (n <= 0) {
        printf("Invalid argument n.");
        return 1;
    }

    f(argv[1], n);

    printf("%s\n", argv[1]);
    return 0;
}
