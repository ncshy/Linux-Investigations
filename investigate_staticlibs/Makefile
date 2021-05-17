CC=gcc
CFLAGS=-Wall -g
CFLAGS_STAT=-Wall -g --static

shared:	hello.o
		$(CC) $(CFLAGS) $^ -o hello_$@

static:	hello.o
		$(CC) $(CFLAGS_STAT) $^ -o hello_$@

clean:
		rm -f hello_static hello_shared hello.o
