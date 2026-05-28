#include <stdio.h>
#include <stdlib.h>
#include "../../f.h"


int main(int argc, char* argv[]) {
    if (argc < 3) {
        printf("Error: Argument missing.\n");
        printf("Usage: %s <string> <int>\n", argv[0]);
        return 1;
    }
    int n = atoi(argv[2]);
    remnth(argv[1], n);
    printf("%s\n", argv[1]);
    return 0;
}
