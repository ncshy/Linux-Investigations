<h2> Type conversion Pitfalls </h2>

In file tconv.c, 2 variables of type 'signed int' and 'unsigned int' are defined. <br>

```
	unsigned int a = 2;
	signed int b = -5;

```

They are then compared with each other: <br>

```
 
 if ( b > a)   // Should be false, but comes out true

```

Since type conversion rules specify that any unsigned type >= signed type, then the signed type converts to an unsigned type. <br>
In this case, 'b' is 0xfffffffb , which is 2^32 - 5 in decimal. <br>

Looking at the assembly instruction, the comparison instruction generated is 'jae' which checks for comparison of unsigned values, confirming the conversion rules were applied here. <br>
```
    1155:	c7 45 f8 02 00 00 00 	mov    DWORD PTR [rbp-0x8],0x2
    115c:	c7 45 fc fb ff ff ff 	mov    DWORD PTR [rbp-0x4],0xfffffffb
    1163:	8b 45 fc             	mov    eax,DWORD PTR [rbp-0x4]
    1166:	39 45 f8             	cmp    DWORD PTR [rbp-0x8],eax
    1169:	73 11                	jae    117c <main+0x33>			<----- Comparison of unsigned values

```

In file tconv_2.c, 2 variables of type 'signed int' and 'unsigned char' are defined. <br>
```
	unsigned char a = 2;
	signed int b = -5;

	if ( b > a)		// Same comparison as before, this time correctly comes out as false. 

```

In this case, type conversion rules specify that if the signed type can hold all values of the unsigned type, then the unsigned type is converted to the signed type. <br>

Looking at the assembly code, we see that is indeed the case with the 'jle' instruction being used for comparison of signed values. <br>
```
    1155:	c6 45 fb 02          	mov    BYTE PTR [rbp-0x5],0x2
    1159:	c7 45 fc fb ff ff ff 	mov    DWORD PTR [rbp-0x4],0xfffffffb
    1160:	0f b6 45 fb          	movzx  eax,BYTE PTR [rbp-0x5]
    1164:	39 45 fc             	cmp    DWORD PTR [rbp-0x4],eax
    1167:	7e 11                	jle    117a <main+0x31>		<----- Comparison of signed values

```

