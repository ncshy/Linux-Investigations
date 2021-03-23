# Investigation of macro functions

**The 3 programs are used to compare the workings of regular, inline and macro functions** <br>

# Observing instruction count
The most important point is the increase in the number of instructions when using function calls instead of macros. <br>
This happens because for each function call, the stack needs to be setup before jumping to the called function. <br>
When done over a million times(due to the loop), the overhead becomes noticeable and can be seen in the form of more instructions and slower performance.

```
# perf stat ./fn_prog
 23,735,286      instructions              #    2.64  insn per cycle 
 0.004341586 seconds time elapsed

# perf stat ./inline_prog
 22,733,635      instructions              #    2.51  insn per cycle  
 0.004338222 seconds time elapsed

# perf stat ./macro_prog
  5,727,163      instructions              #    0.74  insn per cycle  
  0.003820126 seconds time elapsed

```
# Observing source code in Assembly
fn\_prog has to setup the stack as can be seen from instruction address 11c9 to 11d7.
```
$ objdump -d fn_prog
0000000000001190 <main>:
    1190:	f3 0f 1e fa          	endbr64 
    1194:	55                   	push   %rbp
    1195:	48 89 e5             	mov    %rsp,%rbp
    1198:	48 83 ec 20          	sub    $0x20,%rsp
    119c:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax
    11a3:	00 00 
    11a5:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    11a9:	31 c0                	xor    %eax,%eax
    11ab:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%rbp)
    11b2:	c7 45 f0 05 00 00 00 	movl   $0x5,-0x10(%rbp)
    11b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
    11c0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
    11c7:	eb 17                	jmp    11e0 <main+0x50>
    11c9:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
    11cd:	48 8d 45 ec          	lea    -0x14(%rbp),%rax
    11d1:	48 89 d6             	mov    %rdx,%rsi
    11d4:	48 89 c7             	mov    %rax,%rdi
    11d7:	e8 8d ff ff ff       	callq  1169 <fn_prod>   -----> function call
    11dc:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
    11e0:	81 7d f4 3f 42 0f 00 	cmpl   $0xf423f,-0xc(%rbp)
    11e7:	7e e0                	jle    11c9 <main+0x39>
    ...
    ...
```
inline\_prog also has to setup the stack as can be seen from instruction address 11c5 to 11d3. <br>
An inline can work as a macro and it's entirely upto the compiler whether it treats it that way. <br>
In this example, the compiler has chosen to treat the inline function as a regular function. <br>
Hence the performance remains the same.
```
$ objdump -d inline_prog
000000000000118c <main>:
    118c:	f3 0f 1e fa          	endbr64 
    1190:	55                   	push   %rbp
    1191:	48 89 e5             	mov    %rsp,%rbp
    1194:	48 83 ec 20          	sub    $0x20,%rsp
    1198:	64 48 8b 04 25 28 00 	mov    %fs:0x28,%rax
    119f:	00 00 
    11a1:	48 89 45 f8          	mov    %rax,-0x8(%rbp)
    11a5:	31 c0                	xor    %eax,%eax
    11a7:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%rbp)
    11ae:	c7 45 f0 05 00 00 00 	movl   $0x5,-0x10(%rbp)
    11b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
    11bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%rbp)
    11c3:	eb 17                	jmp    11dc <main+0x50>
    11c5:	48 8d 55 f0          	lea    -0x10(%rbp),%rdx
    11c9:	48 8d 45 ec          	lea    -0x14(%rbp),%rax
    11cd:	48 89 d6             	mov    %rdx,%rsi
    11d0:	48 89 c7             	mov    %rax,%rdi
    11d3:	e8 91 ff ff ff       	callq  1169 <inline_prod> -----> function call
    11d8:	83 45 f4 01          	addl   $0x1,-0xc(%rbp)
    11dc:	81 7d f4 3f 42 0f 00 	cmpl   $0xf423f,-0xc(%rbp)
    11e3:	7e e0                	jle    11c5 <main+0x39>
    ...
    ...
```
macro\_prog has the addition logic pasted within the main function as marked below. <br>
This saves instruction count and improves performance. <br>

```
$ objdump -d macro_prog
0000000000001149 <main>:
    1149:	f3 0f 1e fa          	endbr64 
    114d:	55                   	push   %rbp
    114e:	48 89 e5             	mov    %rsp,%rbp
    1151:	48 83 ec 10          	sub    $0x10,%rsp
    1155:	c7 45 f4 03 00 00 00 	movl   $0x3,-0xc(%rbp)
    115c:	c7 45 fc 05 00 00 00 	movl   $0x5,-0x4(%rbp)
    1163:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%rbp)
    116a:	eb 0a                	jmp    1176 <main+0x2d>
    116c:	8b 45 fc             	mov    -0x4(%rbp),%eax
    116f:	01 45 f4             	add    %eax,-0xc(%rbp) ----> addition logic(no function call)
    1172:	83 45 f8 01          	addl   $0x1,-0x8(%rbp) ----> Increment loop counter
    1176:	81 7d f8 3f 42 0f 00 	cmpl   $0xf423f,-0x8(%rbp) ----> Check counter value
    117d:	7e ed                	jle    116c <main+0x23>
    ...
    ...

```

The downside to using  macro functions are, they are unintuitive to write and are quite limited in their capabilities. <br>
This is due to the macro functions being handled by the preprocessor and not the compiler. 


