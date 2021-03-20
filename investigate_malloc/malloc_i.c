#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<string.h>

#define KILOBYTE 1024

int main()
{
    char *astring;
    const char *str = "A beautiful world";
    /* Allocate 1KB of data to astring */
    astring = malloc(KILOBYTE);
    if(!astring)
        printf("Memory allocation failed\n");
    memcpy(astring, str, strlen(str));
    printf("astring address is %llx\n", astring);

    return 0;
}
