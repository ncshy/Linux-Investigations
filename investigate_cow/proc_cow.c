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
    fork_ret = fork();

    if(fork_ret == 0) {
        int m = 3;
	sleep(20);
        a = a + m;		// Modifying a variable whose page frame is shared 
        m *= 2;
	printf("a child: %d\n", a);
	printf("a child address: %p\n", &a);
        exit(0);
    }
    wait(&wstatus);
    a = a * 2;
    printf("a parent: %d\n", a);
    printf("a parent address: %p\n", &a);
}
