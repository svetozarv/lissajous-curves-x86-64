#include <stdio.h>
#include <stdlib.h>
#include "../../f.h"


int main(int argc, char* argv[]) {
    if (argc < 3) {
        printf("Error: Argument missing.\n");
        printf("Usage: %s <string> <int>\n", argv[0]);
        return 1;
    }

    int a = atoi(argv[2]);
    leavelastndig(argv[1], a);

    printf("%s\n", argv[1]);
    return 0;
}
