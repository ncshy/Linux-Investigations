#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

int main() 
{
    int *pid = malloc(sizeof(int));
    char cmd[20];
    memset(cmd, 0, sizeof(cmd));
    *pid = getpid();
   
    sprintf(cmd, "cat /proc/%d/maps", *pid);
    system(cmd);

}
