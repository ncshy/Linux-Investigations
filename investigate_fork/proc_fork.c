#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/wait.h>
#include <string.h>

int main() 
{
    int a = 5;
    pid_t fork_ret;
    int wstatus;
    char str[6] = "Hello";
    char *str2 = malloc(10);

    memcpy(str2, "World", 6);
    fork_ret = fork();
    if(fork_ret == 0) {
        int m = 3;
        a = a + m;
        m *= 2;
		printf("a child: %d\n", a);
        exit(0);
    }
    wait(&wstatus);
    a = a * 2;
	printf("a parent: %d\n", a);
}
