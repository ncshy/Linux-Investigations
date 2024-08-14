TARGET=rec_macro
CFLAGS=-O2
CC=gcc
OBJs=rec_macro.o sum_impl.o

$(TARGET): $(OBJs)
	$(CC) $(CFLAGS) $(OBJs) -o $@

clean:
	rm $(OBJs) $(TARGET)

