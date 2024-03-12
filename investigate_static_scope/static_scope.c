#include<stdio.h>
#include<stdlib.h>

static int a = 5;

int add_static()
{
    /* Adding this block will cause 
     * a compilation error when code
     * outside block tries to access
     * variable val
    {
        static int val = 12;
    }
    */
    static int sum = 10;
    if(sum > 20)
        return sum;
    sum = sum + a;
    sum = add_static();
    return sum;
}

void main() 
{
    int sum_add = add_static();
    printf("sum is %d\n", sum_add);
}
