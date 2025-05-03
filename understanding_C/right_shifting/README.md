# Right shifts for siged and unsigned numbers

The code assigns the same value to 2 variables of size 2 Bytes. <br>

They are then right shifted once, and the new values are printed. <br>

```
	short int a = -32768;
	short unsigned int b = 32768;

	b >>= 1;
	a >>= 1;

```

The assembly language instruction for this code is shown below: <br>
```
0000000000001149 <main>:
    1149:	f3 0f 1e fa          	endbr64 
    114d:	55                   	push   rbp
    114e:	48 89 e5             	mov    rbp,rsp
    1151:	48 83 ec 10          	sub    rsp,0x10
    1155:	66 c7 45 fc 00 80    	mov    WORD PTR [rbp-0x4],0x8000
    115b:	66 c7 45 fe 00 80    	mov    WORD PTR [rbp-0x2],0x8000
    1161:	66 d1 6d fe          	shr    WORD PTR [rbp-0x2],1
    1165:	66 d1 7d fc          	sar    WORD PTR [rbp-0x4],1
    1169:	0f bf 45 fc          	movsx  eax,WORD PTR [rbp-0x4]
    116d:	89 c6                	mov    esi,eax
    116f:	48 8d 05 8e 0e 00 00 	lea    rax,[rip+0xe8e]        # 2004 <_IO_stdin_used+0x4>
    1176:	48 89 c7             	mov    rdi,rax
    1179:	b8 00 00 00 00       	mov    eax,0x0
    117e:	e8 cd fe ff ff       	call   1050 <printf@plt>
    1183:	0f b7 45 fe          	movzx  eax,WORD PTR [rbp-0x2]
    1187:	89 c6                	mov    esi,eax
    1189:	48 8d 05 80 0e 00 00 	lea    rax,[rip+0xe80]        # 2010 <_IO_stdin_used+0x10>
    1190:	48 89 c7             	mov    rdi,rax
    1193:	b8 00 00 00 00       	mov    eax,0x0
    1198:	e8 b3 fe ff ff       	call   1050 <printf@plt>
    119d:	b8 00 00 00 00       	mov    eax,0x0
    11a2:	c9                   	leave  
    11a3:	c3                   	ret    

```

The same value is assigned to both variables in the stack. 
```
    1155:	66 c7 45 fc 00 80    	mov    WORD PTR [rbp-0x4],0x8000
    115b:	66 c7 45 fe 00 80    	mov    WORD PTR [rbp-0x2],0x8000

```
The **signed variable** undergoes the **sar** instruction, which **preserves the sign extension.** <br>
The **unsigned variable** undergoes the **shr** instruction, the logical right shift, which **inserts 0's to the MSb.** <br>
```
    1161:	66 d1 6d fe          	shr    WORD PTR [rbp-0x2],1
    1165:	66 d1 7d fc          	sar    WORD PTR [rbp-0x4],1

```

The values in the 2 variables are then printed out through the printf statements. <br>
```
    1169:	0f bf 45 fc          	movsx  eax,WORD PTR [rbp-0x4]
    116d:	89 c6                	mov    esi,eax
    116f:	48 8d 05 8e 0e 00 00 	lea    rax,[rip+0xe8e]        # 2004 <_IO_stdin_used+0x4>
    1176:	48 89 c7             	mov    rdi,rax
    1179:	b8 00 00 00 00       	mov    eax,0x0
    117e:	e8 cd fe ff ff       	call   1050 <printf@plt>
    1183:	0f b7 45 fe          	movzx  eax,WORD PTR [rbp-0x2]
    1187:	89 c6                	mov    esi,eax
    1189:	48 8d 05 80 0e 00 00 	lea    rax,[rip+0xe80]        # 2010 <_IO_stdin_used+0x10>
    1190:	48 89 c7             	mov    rdi,rax
    1193:	b8 00 00 00 00       	mov    eax,0x0
    1198:	e8 b3 fe ff ff       	call   1050 <printf@plt>

```

The output of both variables are: <br>
```
a is 0xc000
b is 0x4000
```

