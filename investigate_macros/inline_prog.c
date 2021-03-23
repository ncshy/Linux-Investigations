#include <stdio.h>
#include <stdlib.h>

static inline void inline_prod(unsigned int *a, int *b) 
{
    *a = (*a) + (*b);
}

int main() 
{
    unsigned int a = 3;
    int b = 5;
    int i = 0;
    /* Add b to a, million times */        
    for(i = 0; i < 1000000; i++)
      inline_prod(&a, &b);

    printf("Value of a: %u\n", a);
    printf("Value of b: %d\n", b);

    return 0;
}
