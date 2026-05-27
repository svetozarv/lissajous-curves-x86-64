#include <stdio.h>
#include <stdlib.h>
#include "compress.h"


int main(int argc, char* argv[]) {
    if (argc != 2) {
        printf("Error: Argument missing.\n");
        printf("Usage: %s <string>\n", argv[0]);
        return 1;
    }

    compress(argv[1]);
    printf("%s\n", argv[1]);
    return 0;
}
