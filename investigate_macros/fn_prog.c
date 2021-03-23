#include <stdio.h>
#include <stdlib.h>

void fn_prod(unsigned int *a, int *b) 
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
      fn_prod(&a, &b);

    printf("Value of a: %u\n", a);
    printf("Value of b: %u\n", b);

    return 0;
}
