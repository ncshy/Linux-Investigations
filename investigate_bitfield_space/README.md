# Understand how much memory a bitfield implementation takes

## What is a bitfield?
A bitfield in 'C' is a mechanism to quickly set and unset bits of a word, without relying on AND/OR operators <br>

It's generally defined as : <br>
```
struct {
	unsigned int a:1
	unsigned int b:1
	unsigned int c:2
}field;
```

Values can be set or unset using assignment operators <br>

```
field.a = 1;
field.b = 0;
field.c = 0x2;
```

## How much space does it take in memory

In the C code in bitfield_space.c, I have defined a struct that mimics a device register. The fields are show below <br>
```
struct abitfield {
    unsigned int control:1;
    unsigned int status:1;
    unsigned int wr_complete:1;
    unsigned int dma_complete:1;
    unsigned int offload_enable:2;
    unsigned int :26;
    unsigned int mode_select:2;
};

```

The rest of the program is essentially trying to visualize what happens in memory when the fields are set, and how much space it takes <br>
There is a field 'unsigned int :26' which adds zero padding for 26bits. <br>

In the output below, we see the space taken by struct abitfield is 8 Bytes, because an 'unsigned int' is 4B, and once the memory required for the bitfields exceeds 32 bits, another 'unsigned int' worth of memory is allocated. <br>
The output visualizing the bitfield is also shown: <br>
```
size of abitf is 8
abitf value : 20000003f
```

The 3f in the LSB(Least Significant Byte) is due to setting the fields in the code. The 000000 is added due to the 'unsigned int :26' padding in the struct abitfield. <br>
The 2 at the beginning is the mode_select field(set to 2) which is present in the upper 4B of memory. <br>
