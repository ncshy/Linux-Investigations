

<h2> Postincrement: </h2>

```
a = 10
result = a++ + ++a;
```

Higher priority for increment ++ over arithmetic '+' <br>

The assembly for the above code is : <br> 

```

	1155:	c7 45 f8 0a 00 00 00 	mov    DWORD PTR [rbp-0x8],0xa			# Load initial 10 value to stack location
    115c:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]			# Move this 10 to eax register
    115f:	8d 50 01             	lea    edx,[rax+0x1]					# Increment eax value (a++); Not sure why lea is being used here
    1162:	89 55 f8             	mov    DWORD PTR [rbp-0x8],edx			# Store above incremented value to 8B offset from frame pointer
    1165:	83 45 f8 01          	add    DWORD PTR [rbp-0x8],0x1			# Add 1 to dereferenced address (++a)
    1169:	8b 55 f8             	mov    edx,DWORD PTR [rbp-0x8]			# Move final dereferenced value to edx
    116c:	01 d0                	add    eax,edx							# Add eax and edx ( 10 + 12 ) as result
    116e:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax			# Store result 4B offset from frame pointer
    1171:	8b 55 fc             	mov    edx,DWORD PTR [rbp-0x4]			# Store result as 3rd argument to printf function
    1174:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]			# Move variable value 12 to eax	
    1177:	89 c6                	mov    esi,eax							# Store variable as 2nd arg to printf
    1179:	48 8d 05 84 0e 00 00 	lea    rax,[rip+0xe84]        # 2004 <_IO_stdin_used+0x4>		# Load .rodata printf format string address to rax
    1180:	48 89 c7             	mov    rdi,rax							# Move string address as first arg
    1183:	b8 00 00 00 00       	mov    eax,0x0							# No variadic argument
    1188:	e8 c3 fe ff ff       	call   1050 <printf@plt>				# Call printf library function
```

<h2> Preincrement: </h2>

```
a = 10
result = ++a + ++a;
```

Higher priority for increment ++ over arithmetic '+' <br>

The assembly for the above fragment is : <br>

```
0000000000001149 <main>:
    1149:	f3 0f 1e fa          	endbr64
    114d:	55                   	push   rbp
    114e:	48 89 e5             	mov    rbp,rsp
    1151:	48 83 ec 10          	sub    rsp,0x10							# Move stack pointer 16B down
    1155:	c7 45 f8 0a 00 00 00 	mov    DWORD PTR [rbp-0x8],0xa			# Move variable value 10 to stack at byte offset 8, from the frame pointer
    115c:	83 45 f8 01          	add    DWORD PTR [rbp-0x8],0x1			# Add 1 to this variable
    1160:	83 45 f8 01          	add    DWORD PTR [rbp-0x8],0x1			# Add 1 again to this variable
    1164:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]			# Move variable value to eax
    1167:	01 c0                	add    eax,eax							# Add both operands of the addition after the pre-increment stage
    1169:	89 45 fc             	mov    DWORD PTR [rbp-0x4],eax			# Store result on the stack at byte offset 4 from the frame pointer
    116c:	8b 55 fc             	mov    edx,DWORD PTR [rbp-0x4]			# Move result to edx (3rd argument)
    116f:	8b 45 f8             	mov    eax,DWORD PTR [rbp-0x8]			# Move variable to eax
    1172:	89 c6                	mov    esi,eax							# Move eax to esi (2nd argument)
    1174:	48 8d 05 89 0e 00 00 	lea    rax,[rip+0xe89]        # 2004 <_IO_stdin_used+0x4>	
    117b:	48 89 c7             	mov    rdi,rax							# Move .rodata format string as 1st argument
    117e:	b8 00 00 00 00       	mov    eax,0x0
    1183:	e8 c8 fe ff ff       	call   1050 <printf@plt>				# Call printf
```

<h3> Lingering doubts </h3>

I am not sure why the below statement was generated. What is the point of doing an 'load effective address' operation at this point. 
```
    115f:	8d 50 01             	lea    edx,[rax+0x1]					# Increment eax value (a++); Not sure why lea is being used here
```

So far, searching the internet has not produced a satisfactory reason for this statement. 
