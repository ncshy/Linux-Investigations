# Investigations into a stack call

**Investigating stack handling during a function call, on an ARM 32-bit architecture.** <br>
The following code was obtained by, disassembling the executable generated from the call\_afunc.c, using the GNU crosschain tool's 'objdump'.
```
000083e4 <add_vars>:
   83e4:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
    83e8:	e28db000 	add	fp, sp, #0
    83ec:	e24dd00c 	sub	sp, sp, #12
    83f0:	e50b0008 	str	r0, [fp, #-8]
    83f4:	e50b100c 	str	r1, [fp, #-12]
    83f8:	e51b2008 	ldr	r2, [fp, #-8]
    83fc:	e51b300c 	ldr	r3, [fp, #-12]
    8400:	e0823003 	add	r3, r2, r3
    8404:	e1a00003 	mov	r0, r3
    8408:	e24bd000 	sub	sp, fp, #0
    840c:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
    8410:	e12fff1e 	bx	lr

00008414 <main>:
    8414:	e92d4800 	push	{fp, lr}
    8418:	e28db004 	add	fp, sp, #4
    841c:	e24dd008 	sub	sp, sp, #8
    8420:	e3a0300a 	mov	r3, #10
    8424:	e50b3008 	str	r3, [fp, #-8]
    8428:	e3a03005 	mov	r3, #5
    842c:	e50b300c 	str	r3, [fp, #-12]
    8430:	e51b0008 	ldr	r0, [fp, #-8]
    8434:	e51b100c 	ldr	r1, [fp, #-12]
    8438:	ebffffe9 	bl	83e4 <add_vars>
    843c:	e50b0008 	str	r0, [fp, #-8]
    8440:	e3a03000 	mov	r3, #0
    8444:	e1a00003 	mov	r0, r3
    8448:	e24bd004 	sub	sp, fp, #4
    844c:	e8bd8800 	pop	{fp, pc}

```
# Introducing the registers

```
fp - Frame pointer/Base pointer
sp - Stack pointer
r0-r10 - General purpose registers
pc - Program counter(Instruction pointer) register
lr - Link register
```

# Introducing the instructions
```
mov - Moves data between registers
str - Store word from register into memory
sub - Subtracts 3rd argument from 2nd argument value and stores result in the leftmost argument
add - Adds register values, stores result in leftmost argument
push - Decrement sp by 4*(no.of arguments) and push the argument onto the stack in order.
pop - Pop the element on the stack pointed to by sp, store it in the argument, then increment sp 
bl - Store next pc value onto lr, and jump to address specified
bx - Copy value in lr and store it in pc.

```
# Main function instructions

The first instruction is 
```
8414:	e92d4800 	push	{fp, lr}
```
This pushes the previous frame pointer fp at (sp - 8) and link register lr onto the stack at (sp - 4) and decrements the sp value by 8(for 32bit system, addresses are 4 bytes). <br>
Also note that the stack grows downward for ARM32 system. <br>

```
    8418:	e28db004 	add	fp, sp, #4
    841c:	e24dd008 	sub	sp, sp, #8
```
Here the frame pointer register is 'sp + 4'. Thus this is the beginning of the main function stack frame. Points to the saved lr entry on stack <br>
So in effect, there will be multiple frames within a stack including nested frames(in case of nested function calls). <br>
stack pointer is then set to location 'sp - 8' or 2 words below the current sp. This space is saved for storing local variables 'a' and 'b'.

```
    8420:	e3a0300a 	mov	r3, #10
    8424:	e50b3008 	str	r3, [fp, #-8]
    8428:	e3a03005 	mov	r3, #5
    842c:	e50b300c 	str	r3, [fp, #-12]
```
Copy the immediate/constant values 10 and 5 onto the stack(representing local variables 'a' and 'b') using the register r3 as an intermediate. <br>
r3 has to be used, since 'str' instruction can only move data between registers and memory. 

```
    8430:	e51b0008 	ldr	r0, [fp, #-8]
    8434:	e51b100c 	ldr	r1, [fp, #-12]
```
Load the local variable values as into registers that act as arguments to the function call. In this case using 2 registers(r0 and r1).

```
    8438:	ebffffe9 	bl	83e4 <add_vars>
```
Call the function at address 83e4(which is add\_vars). <br>
The bl will automatically store the next eip value(843c) onto the lr before jumping to the new function.

 add\_vars function instructions

```
    83e4:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
    83e8:	e28db000 	add	fp, sp, #0
    83ec:	e24dd00c 	sub	sp, sp, #12
```
Similar to before, the base stack frame pointer of the main function(previous stack frame) is copied onto the stack at (sp - 4), and then sp is decremented by 4. <br>
After which, the sp value is copied to fp, and this becomes the base stack frame pointer to the add\_vars stack frame.
The sp decrements by 12 and leaves space for 3 words.

```
    83f0:	e50b0008 	str	r0, [fp, #-8]
    83f4:	e50b100c 	str	r1, [fp, #-12]
    83f8:	e51b2008 	ldr	r2, [fp, #-8]
    83fc:	e51b300c 	ldr	r3, [fp, #-12]
```
The two arguments are copied from the register(r0 and r1) onto the stack. <br>
From stack they are copied onto 2 registers(r2 and r3) which will be used for arithmetic instruction.

```
    8400:	e0823003 	add	r3, r2, r3
    8404:	e1a00003 	mov	r0, r3
```
Add the 2 values and store the result in r3 register. <br>
Copy the final value onto the return value register r0.
```
    8408:	e24bd000 	sub	sp, fp, #0
    840c:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
    8410:	e12fff1e 	bx	lr
```
Set sp back to top of stack frame.
Pop the top of stack holding previous frame pointer and store it in fp. Increment sp=sp+4 <br>
bx instruction will copy the value in lr register to pc register.<br>
Thus, the next instruction will be at adress 843c.

# Back to main function
```
    843c:	e50b0008 	str	r0, [fp, #-8]
    8440:	e3a03000 	mov	r3, #0
    8444:	e1a00003 	mov	r0, r3
```
r0 register holds the return value from the add\_vars function. <br>
This is moved to location -0x8(%fp), overwriting the previous value of variable 'a', which is what we expect since (a = add\_vars(a, b)). <br>
Clear the value in the r0 register. <br>

These are the important instructions that display the stack handling part of the program. <br>
Upon a function call, it saves the next pc value to lr register, and passes arguments to the called function. <br>
The called function, deals with preserving the previous stack frame base values, with reading the function arguments, and upon return copying the lr register to the pc register. 

