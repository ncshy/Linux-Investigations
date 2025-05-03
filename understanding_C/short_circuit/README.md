<h2> Short circuiting behaviour of && and || operators </h2>

In the example code, 'a' is one of 4 variables and the code checks if a is the smallest unique value, using the && operator: <br>
```
	if (a < b && a < c && a < d) {
		printf("%d is smallest element\n", a);
	} else {
		printf("%d is not the smallest element\n", a);
	}

```

Below is the assembly code generated for the main function <br>
```
0000000000001149 <main>:
    1149:	f3 0f 1e fa          	endbr64
    114d:	55                   	push   rbp
    114e:	48 89 e5             	mov    rbp,rsp
    1151:	48 83 ec 10          	sub    rsp,0x10
    1155:	c7 45 f0 14 00 00 00 	mov    DWORD PTR [rbp-0x10],0x14
    115c:	c7 45 f4 0a 00 00 00 	mov    DWORD PTR [rbp-0xc],0xa
    1163:	c7 45 f8 05 00 00 00 	mov    DWORD PTR [rbp-0x8],0x5
    116a:	c7 45 fc 02 00 00 00 	mov    DWORD PTR [rbp-0x4],0x2
    1171:	8b 45 f0             	mov    eax,DWORD PTR [rbp-0x10]
    1174:	3b 45 f4             	cmp    eax,DWORD PTR [rbp-0xc]
    1177:	7d 2b                	jge    11a4 <main+0x5b>
    1179:	8b 45 f0             	mov    eax,DWORD PTR [rbp-0x10]
    117c:	3b 45 f8             	cmp    eax,DWORD PTR [rbp-0x8]
    117f:	7d 23                	jge    11a4 <main+0x5b>
    1181:	8b 45 f0             	mov    eax,DWORD PTR [rbp-0x10]
    1184:	3b 45 fc             	cmp    eax,DWORD PTR [rbp-0x4]
    1187:	7d 1b                	jge    11a4 <main+0x5b>
    1189:	8b 45 f0             	mov    eax,DWORD PTR [rbp-0x10]
    118c:	89 c6                	mov    esi,eax
    118e:	48 8d 05 73 0e 00 00 	lea    rax,[rip+0xe73]        # 2008 <_IO_stdin_used+0x8>
    1195:	48 89 c7             	mov    rdi,rax
    1198:	b8 00 00 00 00       	mov    eax,0x0
    119d:	e8 ae fe ff ff       	call   1050 <printf@plt>
    11a2:	eb 19                	jmp    11bd <main+0x74>
    11a4:	8b 45 f0             	mov    eax,DWORD PTR [rbp-0x10]
    11a7:	89 c6                	mov    esi,eax
    11a9:	48 8d 05 70 0e 00 00 	lea    rax,[rip+0xe70]        # 2020 <_IO_stdin_used+0x20>
    11b0:	48 89 c7             	mov    rdi,rax
    11b3:	b8 00 00 00 00       	mov    eax,0x0
    11b8:	e8 93 fe ff ff       	call   1050 <printf@plt>
    11bd:	b8 00 00 00 00       	mov    eax,0x0
    11c2:	c9                   	leave
    11c3:	c3                   	ret
```

The 4 variables are stored in the stack, with values 20,10,5 and 2. <br>
```
    1155:	c7 45 f0 14 00 00 00 	mov    DWORD PTR [rbp-0x10],0x14
    115c:	c7 45 f4 0a 00 00 00 	mov    DWORD PTR [rbp-0xc],0xa
    1163:	c7 45 f8 05 00 00 00 	mov    DWORD PTR [rbp-0x8],0x5
    116a:	c7 45 fc 02 00 00 00 	mov    DWORD PTR [rbp-0x4],0x2

```
The value of a is moved to register eax and then compared with the value of 'b' at rbp-0xc. <br>
If a >= b, then the condition fails an there is jump to address 11a4. <br>
**Thus bypassing all the other checks and short circuiting the operation. ** <br>
```
    1171:	8b 45 f0             	mov    eax,DWORD PTR [rbp-0x10]
    1174:	3b 45 f4             	cmp    eax,DWORD PTR [rbp-0xc]
    1177:	7d 2b                	jge    11a4 <main+0x5b>
```

The value of a is passed as 2nd argument and the format string as the 1st argument to the function printf() <br>
```
    11a4:	8b 45 f0             	mov    eax,DWORD PTR [rbp-0x10]
    11a7:	89 c6                	mov    esi,eax
    11a9:	48 8d 05 70 0e 00 00 	lea    rax,[rip+0xe70]        # 2020 <_IO_stdin_used+0x20>
    11b0:	48 89 c7             	mov    rdi,rax
    11b3:	b8 00 00 00 00       	mov    eax,0x0
    11b8:	e8 93 fe ff ff       	call   1050 <printf@plt>
```
