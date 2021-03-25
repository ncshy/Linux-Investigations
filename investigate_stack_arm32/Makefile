CC=arm-linux-gnueabihf-gcc
CFLAGS=-g -Wall
OBJS=call_afunc.o
BIN=call_afunc_arm

$(BIN):	$(OBJS)
	$(CC) $(CFLAGS) $^ -o $@
	rm $^

clean:
	rm $(BIN)
    
