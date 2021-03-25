# Investigations into a stack call

**Investigating stack handling during a function call, on an ARM 64-bit architecture.** <br>
The following code was obtained by, disassembling the executable generated from the call\_afunc.c, using the GNU crosschain tool's 'objdump'.
```
000000000000071c <add_vars>:
 71c:	d10043ff 	sub	sp, sp, #0x10
 720:	b9000fe0 	str	w0, [sp, #12]
 724:	b9000be1 	str	w1, [sp, #8]
 728:	b9400fe1 	ldr	w1, [sp, #12]
 72c:	b9400be0 	ldr	w0, [sp, #8]
 730:	0b000020 	add	w0, w1, w0
 734:	910043ff 	add	sp, sp, #0x10
 738:	d65f03c0 	ret

000000000000073c <main>:
 73c:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
 740:	910003fd 	mov	x29, sp
 744:	52800140 	mov	w0, #0xa                   	// #10
 748:	b9001be0 	str	w0, [sp, #24]
 74c:	528000a0 	mov	w0, #0x5                   	// #5
 750:	b9001fe0 	str	w0, [sp, #28]
 754:	b9401fe1 	ldr	w1, [sp, #28]
 758:	b9401be0 	ldr	w0, [sp, #24]
 75c:	97fffff0 	bl	71c <add_vars>
 760:	b9001be0 	str	w0, [sp, #24]
 764:	52800000 	mov	w0, #0x0                   	// #0
 768:	a8c27bfd 	ldp	x29, x30, [sp], #32
 76c:	d65f03c0 	ret

```
# Introducing the registers

```
x29 - Frame pointer/Base pointer
sp - Stack pointer
x0-x30 - General purpose registers(8 byte)
w0-w30 - General purpose registers(4 byte)
pc - Instruction pointer register
x30 - Link register
```

# Introducing the instructions
```
mov - Moves data between registers
str - Store word from register into memory
sub - Subtracts 3rd argument from 2nd argument value and stores result in the leftmost argument
add - Adds register values, stores result in leftmost argument
stp - Push the argument onto the stack, then decrement stack pointer to a 16byte boundary.
ldp - Pop the element on the stack pointed to by sp, store it in the argument, then increment sp 
bl - Store next instruction pointer onto x30, and jump to address specified
ret - Copy value in x30 to pc.

```
# Main function instructions

The first instruction is 
```
73c:	a9be7bfd 	stp	x29, x30, [sp, #-32]!
```
This pushes the previous frame pointer fp and link register lr onto the stack at (sp - 32) and (sp - 24) and decrements the sp value by 32(for 64bit system, addresses are 8 bytes). <br>
Also note that the stack grows downward for ARM32 system, although the ordering of entries into stack is changed. <br>
For ARM32 the ordering was [ old sp address---\> lr | fp | local var | local var| <---new sp address ] <br>
For ARM64, the ordering is [ old sp address---\> local var| local var | lr | fp <---new sp address ]<br>
The sp register has to be aligned on a 16byte boundary in ARM64. <br>

```
 740:	910003fd 	mov	x29, sp
```
Here the frame pointer register is given the value of sp register.  Thus this is the beginning of the main function stack frame. Points to the saved fp entry on stack <br>
So in effect, there will be multiple frames within a stack including nested frames(in case of nested function calls). <br>
The stack already created space for storing local variables.

```
 744:	52800140 	mov	w0, #0xa                   	// #10
 748:	b9001be0 	str	w0, [sp, #24]
 74c:	528000a0 	mov	w0, #0x5                   	// #5
 750:	b9001fe0 	str	w0, [sp, #28]
```
Copy the immediate/constant values 10 and 5 onto the stack(representing local variables 'a' and 'b') using the register w0 as an intermediate. <br>
w0 has to be used, since 'str' instruction can only move data between registers and memory. <br>
'w' represents 32bit value, so both the variables can be stored in a single address on stack as 4byte + 4byte. <br>

```
 754:	b9401fe1 	ldr	w1, [sp, #28]
 758:	b9401be0 	ldr	w0, [sp, #24]
```
Load the local variable values as into registers that act as arguments to the function call. In this case using 2 registers(w0 and w1).

```
 75c:	97fffff0 	bl	71c <add_vars>
```
Call the function at address 71c(which is add\_vars). <br>
The bl will automatically store the next pc value(760) onto the link register(x30) before jumping to the new address.

 add\_vars function instructions

```
 71c:	d10043ff 	sub	sp, sp, #0x10
```
sp is decremented by 16 and the arguments to the function, are stored in the stack. <br>
There is no creation of a new stack frame, most probably an optimization by the compiler.

```
 720:	b9000fe0 	str	w0, [sp, #12]
 724:	b9000be1 	str	w1, [sp, #8]
 728:	b9400fe1 	ldr	w1, [sp, #12]
 72c:	b9400be0 	ldr	w0, [sp, #8]
```
The two arguments are copied from the register(w0 and w1) onto the stack. <br>
From stack they are copied onto 2 registers(w1 and w0) which will be used for arithmetic instruction.

```
 730:	0b000020 	add	w0, w1, w0
```
Add the 2 values and store the result in w0 register, which also will hold the return value. <br>
```
 734:	910043ff 	add	sp, sp, #0x10
 738:	d65f03c0 	ret
```
Set sp back to top of stack frame.
bx instruction will copy the value in lr register onto pc register. <br>
Thus, the next instruction will be at address 760.

# Back to main function
```
 760:	b9001be0 	str	w0, [sp, #24]
 764:	52800000 	mov	w0, #0x0                   	// #0
```
w0 register holds the return value from the add\_vars function. <br>
This is moved to location +24(%sp), overwriting the previous value of variable 'a', which is what we expect since (a = add\_vars(a, b)). <br>
Clear the value in the w0 register. <br>

These are the important instructions that display the stack handling part of the program. <br>
Upon a function call, it saves the next instruction pointer, and passes arguments to the called function. <br>
The called function, deals with preserving the previous stack frame base values, with reading the function arguments, and upon return copying the return instruction pointer to the pc register. 

