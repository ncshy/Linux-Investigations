# Investigations into a stack call

**Investigating stack handling during a function call, on an x86-64 architecture.** <br>
The following code was obtained by, disassembling the executable generated from the call\_afunc.c, using the GNU tool 'objdump'.
```
0000000000001129 <add_vars>:
    1129:	f3 0f 1e fa          	endbr64
    112d:	55                   	push   %rbp
    112e:	48 89 e5             	mov    %rsp,%rbp
    1131:	89 7d fc             	mov    %edi,-0x4(%rbp)
    1134:	89 75 f8             	mov    %esi,-0x8(%rbp)
    1137:	8b 55 fc             	mov    -0x4(%rbp),%edx
    113a:	8b 45 f8             	mov    -0x8(%rbp),%eax
    113d:	01 d0                	add    %edx,%eax
    113f:	5d                   	pop    %rbp
    1140:	c3                   	retq

0000000000001141 <main>:
    1141:	f3 0f 1e fa          	endbr64
    1145:	55                   	push   %rbp
    1146:	48 89 e5             	mov    %rsp,%rbp
    1149:	48 83 ec 10          	sub    $0x10,%rsp
    114d:	c7 45 f8 0a 00 00 00 	movl   $0xa,-0x8(%rbp)
    1154:	c7 45 fc 05 00 00 00 	movl   $0x5,-0x4(%rbp)
    115b:	8b 55 fc             	mov    -0x4(%rbp),%edx
    115e:	8b 45 f8             	mov    -0x8(%rbp),%eax
    1161:	89 d6                	mov    %edx,%esi
    1163:	89 c7                	mov    %eax,%edi
    1165:	e8 bf ff ff ff       	callq  1129 <add_vars>
    116a:	89 45 f8             	mov    %eax,-0x8(%rbp)
    116d:	b8 00 00 00 00       	mov    $0x0,%eax
    1172:	c9                   	leaveq
    1173:	c3                   	retq
    1174:	66 2e 0f 1f 84 00 00 	nopw   %cs:0x0(%rax,%rax,1)
    117b:	00 00 00
    117e:	66 90                	xchg   %ax,%ax
```

# Introducing the registers

```
rbp - Frame pointer/Base pointer
rsp - Stack pointer
eax, edx, edi, esi - General purpose registers
eip - Instruction pointer register
```

# Introducing the instructions
```
mov - Moves data between registers
movl - Move a raw value to register
sub - Subtracts value from a register and stores result in the rightmost argument
add - Adds register values, stores result in rightmost argument
push - Decrement rsp and push the argument onto the stack
pop - Pop the element on the stack pointed to by rsp, store it in the argument, then increment rsp 
callq - Store current instruction pointer onto stack, and jump to address specified
retq - Pop value in stack pointed to by esp, store it in eip, then increment rsp

```
# Main function instructions

The second instruction is 
```
1145:   55                      push   %rbp
```
This  decrements the rsp value by 8(for 64bit system, addresses are 8 bytes) and pushes the previous frame pointer rbp(or also called base pointer) onto the stack.<br>
Also note that the stack grows downward for x86 system. <br>

```
   1146:   48 89 e5                mov    %rsp,%rbp
```
Here the stack pointer is copied to frame pointer register. Thus this is the beginning of the main function stack frame. <br>
So in effect, there will be multiple frames within a stack including nested frames(in case of nested function calls).

```
1149:   48 83 ec 10             sub    $0x10,%rsp
```
Subtracts the stack pointer by 16 bytes.

```
    114d:	c7 45 f8 0a 00 00 00 	movl   $0xa,-0x8(%rbp)
    1154:	c7 45 fc 05 00 00 00 	movl   $0x5,-0x4(%rbp)
    115b:	8b 55 fc             	mov    -0x4(%rbp),%edx
    115e:	8b 45 f8             	mov    -0x8(%rbp),%eax

```
Copy the constant values 10 and 5 onto the stack(local variables 'a' and 'b') and also copy it onto 2 GPR's edx and eax. <br>
As can be seen, either 'rsp' or 'rbp' can be used as a reference point to address other locations on the stack. 

```
    1161:	89 d6                	mov    %edx,%esi
    1163:	89 c7                	mov    %eax,%edi
```
Copy the values as arguments to the function call. In this case using 2 registers(esi and edi).

```
    1165:	e8 bf ff ff ff       	callq  1129 <add_vars>
```
Call the function at address 1129(which is add\_vars). <br>
The callq will automatically decrement the rsp pointer by 8 and store the next eip value(116a) onto the stack before jumping to the new function.

# add\_vars function instructions

```
    112d:	55                   	push   %rbp
    112e:	48 89 e5             	mov    %rsp,%rbp
```
Similar to before, rsp is decremented by 8 and then the base stack frame pointer of the main function(previous stack frame) is copied onto the stack.<br>
After which, the new rsp is copied to rbp, and this becomes the base stack frame pointer to the add\_vars stack frame.

```
    1131:	89 7d fc             	mov    %edi,-0x4(%rbp)
    1134:	89 75 f8             	mov    %esi,-0x8(%rbp)
    1137:	8b 55 fc             	mov    -0x4(%rbp),%edx
    113a:	8b 45 f8             	mov    -0x8(%rbp),%eax
```
The two arguments are copied from the register(edi and esi) onto the stack. <br>
From stack they are copied onto 2 registers(edx and eax) which will be used for arithmetic instruction

```
    113d:	01 d0                	add    %edx,%eax
```
Add the 2 values and store the result in eax register.
```
    113f:	5d                   	pop    %rbp
    1140:	c3                   	retq
```
Pop the top of stack and store it in the base frame pointer. Increment rsp=rsp+8 <br>
rsp now points to stack location containing return instruction pointer(116a). <br>
retq instruction will pop this value from the stack, and store it in eip register.  <br>
Thus, the next instruction will be at adress 116a.

# Back to main function
```
    116a:	89 45 f8             	mov    %eax,-0x8(%rbp)
    116d:	b8 00 00 00 00       	mov    $0x0,%eax
```
eax register holds the return value from the add\_vars function. <br>
This is moved to location -0x8(%rbp), overwriting the previous value of variable 'a', which is what we expect since (a = add\_vars(a, b)). <br>
Clear the value in the eax register. <br>

These are the important instructions that display the stack handling part of the program. <br>
Upon a function call, it saves the next instruction pointer, and passes arguments to the called function. <br>
The called function, deals with preserving the previous stack frame base values, with reading the function arguments, and upon return copying the return instruction pointer to the eip register. 

