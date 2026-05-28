#include <stdio.h>
#include <stdlib.h>
#include "../../f.h"


int main(int argc, char* argv[]) {
    if (argc < 4) {
        printf("Error: Argument missing.\n");
        printf("Usage: %s <string> <char> <char>\n", argv[0]);
        return 1;
    }

    char a = *argv[2];
    char b = *argv[3];
    if (a == '\0' || b == '\0') {
        printf("Provide argv[2] and argv[3].");
        return 1;
    }
    printf("a = %d\n", a);
    printf("b = %d\n", b);

    leaverng(argv[1], a, b);

    printf("%s\n", argv[1]);
    return 0;
}
