#include <stdio.h>
#include <stdlib.h>

int main() {

    volatile int a = 10;
    int sum = 0;

    for(int i = 0; i < 10; i++) {
        a = i;
        asm volatile("" ::: "memory");
        sum += a;
    }

}
