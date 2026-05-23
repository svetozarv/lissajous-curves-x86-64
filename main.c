#include <stdio.h>
#include <stdlib.h>
#include "f.h"



int main(int argc, char* argv[]) {
    if (argc < 4) {
        printf("Error: Argument missing.\n");
        printf("Usage: %s <string> <char> <char>\n", argv[0]);
        return 1;
    }

    char a = *argv[2];
    char b = *argv[3];
    if (a == '\0' || b == '\0') {
        printf("Invalid argument.");
        return 1;
    }
    printf("%d\n", a);
    printf("%d\n", b);
    remrep(argv[1]);

    printf("%s\n", argv[1]);
    return 0;
}
