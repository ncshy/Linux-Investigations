#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <unistd.h>
#include <stdint.h>
#include <signal.h>
#include <sys/types.h>

void handler(int val) 
{
   pid_t pid;
   pid = getpid();
   printf("Caught SIGINT in process: %d\n", pid); 
   /* Reset signal handler to default */
   signal(SIGINT, SIG_DFL); 
}

void *thread_func(void *arg) 
{
    uint32_t val = (1<<31);
    int i;
    int a = 0;
    int id = 0;
    if(arg != NULL)
        id = *(int *)arg;
    printf("Thread %d process id is: %d\n", id, getpid());
    printf("Thread %d thread id is: %d\n", id, gettid());
    while(1) {
        /* Just some operation to occupy the CPU */
        for(i = 0; i < val; i++)
            a+=1;
        /* Let thread sleep for 1 second */
        sleep(1);    
        printf("Thread fun %d\n", id);
    }
    return NULL;
}

int main()
{
    pthread_t thr1, thr2;
    int ret;
    int thr1_id = 1;
    int thr2_id = 2;
    signal(SIGINT, &handler);
    printf("Main Thread process id is: %d\n", getpid());
    printf("Main Thread thread id is: %d\n", gettid());
    /* Create threads thr1 and thr2 */
    ret = pthread_create(&thr1, NULL, &thread_func, &thr1_id);
    if(ret < 0) {
        printf("Failed to create thread\n");
        return 1;
    }
    ret = pthread_create(&thr2, NULL, &thread_func, &thr2_id);
    if(ret < 0) {
        printf("Failed to create thread\n");
        return 1;
    }
    /* Wait for threads to complete */
    ret = pthread_join(thr1, NULL);
    if(ret < 0) {
        printf("Failure in thread join\n");
        return 1;
    }
    ret = pthread_join(thr2, NULL);
    if(ret < 0) {
        printf("Failure in thread join\n");
        return 1;
    }
    return 0;
}
