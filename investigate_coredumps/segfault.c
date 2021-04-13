#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/resource.h>

int main()
{
    int *val = NULL;
    int count = 3;
    
    struct rlimit *limit = malloc(sizeof(struct rlimit));
    /* Get current rlimit_core */
    getrlimit(RLIMIT_CORE, limit);
    /* Set current rlimit core to about 500KB */
    limit->rlim_cur = 500000;
    if(limit->rlim_cur < limit->rlim_max)
        setrlimit(RLIMIT_CORE, (const struct rlimit *)limit);
   
    /* Code that segfaults */
    for(int i = 0; i < count; i++) {
        *val = *val + *val;
    }
    printf("val is %d\n", *val);
}
