## Empty string representation in memory 

We define a array of strings in the program, each string length is assigned a memory of 10 bytes. <br>
```
#define MAX_LEN 10

char list_str[][MAX_LEN] = {"one", "two", "", "three"};
```

We then calculate the length of the string array, and the number of elements in it. In this example there are 4 such strings in the array <br>
Inside the loop, each byte in the array of string representation is being printed out in hexadecimal format. <br>
This is done to see how the string data is represented in memory. <br>

```
int list_len = sizeof(list_str)/(MAX_LEN * sizeof(char));
char *str = &list_str[0][0];

for (int i = 0; i < list_len * MAX_LEN; i++) {
	if (i % MAX_LEN == 0)
		printf("\n");
	printf("%x ", str[i]);
}

```

The output of running the program is below: <br>
```
6f 6e 65 0 0 0 0 0 0 0		// one
74 77 6f 0 0 0 0 0 0 0 		// two
0 0 0 0 0 0 0 0 0 0 		// ""
74 68 72 65 65 0 0 0 0 0	// three
```
Thus showing that the empty string "" is simply a '\0' character at index 0 of the character array. <br>

We can see the same from the assembly instructions for this binary, where the data is in LITTLE ENDIAN format <br>
```
11a4:	48 c7 45 d0 6f 6e 65 	mov    QWORD PTR [rbp-0x30],0x656e6f	// one 
11ab:	00 
11ac:	66 c7 45 d8 00 00    	mov    WORD PTR [rbp-0x28],0x0		// 8 bytes moved earlier + 2 bytes here to make it 10B (memory assigned for each string)
11b2:	48 c7 45 da 74 77 6f 	mov    QWORD PTR [rbp-0x26],0x6f7774	// two
11b9:	00 
11ba:	66 c7 45 e2 00 00    	mov    WORD PTR [rbp-0x1e],0x0		// 8 bytes moved earlier + 2 bytes here to make it 10B (memory assigned for each string)
11c0:	48 c7 45 e4 00 00 00 	mov    QWORD PTR [rbp-0x1c],0x0			// ""
11c7:	00 
11c8:	66 c7 45 ec 00 00    	mov    WORD PTR [rbp-0x14],0x0		// 8 bytes moved earlier + 2 bytes here to make it 10B (memory assigned for each string)
11ce:	48 b8 74 68 72 65 65 	movabs rax,0x6565726874
11d5:	00 00 00 
11d8:	48 89 45 ee          	mov    QWORD PTR [rbp-0x12],rax			// three
11dc:	66 c7 45 f6 00 00    	mov    WORD PTR [rbp-0xa],0x0		// 8 bytes moved earlier + 2 bytes here to make it 10B (memory assigned for each string)
11e2:	c7 45 c4 04 00 00 00 	mov    DWORD PTR [rbp-0x3c],0x4			// Number of strings is 4.

```
