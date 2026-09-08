TARGET=ip_bitfield

$(TARGET): $(TARGET).o
	gcc $^ -o $@

$(TARGET).o: 
	gcc -c $(TARGET).c -o $@

clean:
	rm $(TARGET).o $(TARGET)

