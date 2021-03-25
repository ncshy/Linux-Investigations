#include<stdio.h>
#include<stdlib.h>

int add_vars(int a, int b)
{
    return a + b;
}

int main() 
{
    int a = 10;
    int b = 5;
    a = add_vars(a,b);

    return 0;
}
