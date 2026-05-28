#include <stdio.h>
#include <stdlib.h>
#include "../../f.h"


int main(int argc, char* argv[]) {
    if (argc != 2) {
        printf("Usage: %s <string>\n", argv[0]);
        return 1;
    }
    remrep(argv[1]);
    printf("%s\n", argv[1]);
    return 0;
}
