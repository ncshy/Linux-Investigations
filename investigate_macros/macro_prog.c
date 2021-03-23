#include <stdio.h>
#include <stdlib.h>
#define prod(a, b) ({  \
                        a + b; \
                       })

int main() 
{
    unsigned int a = 3;
    int b = 5;
    int i;
    /* Add b to a, million times */
    for(i = 0; i < 1000000; i++)
        a = prod(a, b);

    printf("Value of a: %u\n", a);
    printf("Value of b: %d\n", b);

    return 0;
}
