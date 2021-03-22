#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#define FILENAME "textfile.txt"
#define SHARED
int main()
{
    int fd;
    char *mmap_addr;

    /* Opening the file */
    fd = open(FILENAME, O_RDWR);
    if(fd < 0) {
        printf("Could not open file\n");
        return -1;
    }
    /* Mapping opened file to process address space */
#ifdef SHARED
    mmap_addr = mmap(NULL, 20, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
#else
    mmap_addr = mmap(NULL, 20, PROT_READ|PROT_WRITE, MAP_PRIVATE, fd, 0);
#endif
    if(mmap_addr == (void *)-1) {
        printf("Could not create mapping\n");
        close(fd);
        return -1;
    }
    close(fd);
    /* Modifying content within address, in effect altering file content */ 
    mmap_addr[0] = 'Y';
    /* Unmapping file from process address space */
    if(munmap(mmap_addr, 20) < 0) {
        printf("Failed to unmap\n");
        return -1;
    }
    return 0;
}

