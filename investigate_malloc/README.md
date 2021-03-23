# Investigate malloc's underbelly

I have always wondered what happens after a malloc call is issued. This was especially true after I was asked this in an interview. I knew that brk() was called, but didn't know what happens beyond that.
So here I will explain what happens using strace tools and some theoretical concepts.

When the program is traced, the following 2 statements are produced. These deal with the malloc call. 

    brk(NULL)                               = 0x55ff09543000
    brk(0x55ff09564000)                     = 0x55ff09564000

To get an idea of the abstractions, malloc is a standard library, meaning its a wrapper for a lower level call.

**The flow is shown below**

user----invokes---\> malloc() ----invokes----\> brk() ----invokes----\> sys\_brk()

**So what happens inside the sys\_brk()?** To understand this, it's time to delve into the Linux Kernel and some of its resident housekeepers.

First things, a process is a program in execution. That means, the program is read from a file(normally in disk) and loaded into memory(RAM). 
The file is an ELF executable(not important for now), which organizes the program into segments:

Data segment

Code/Text segment

Read only data segment

These same sections are also loaded into memory. But who keeps track of all these details? This is where the Linux Kernel comes in.
The Kernel has a structure for each process called 'mm', which stands for memory management.

    struct mm {
        ...
        ...
        ...


    unsigned long start_brk;
    unsigned long brk;


    };

These 2 are the fields which interest us for now.
So each process's memory manager, has a **'start\_brk field'**, which signifies the start of the heap memory(dynamically allocated memory). 
The **'brk field'** holds the end of dynamic memory presently. 

When sys\_brk() is called with NULL argument, it returns the value of brk field. Thus you can see that in my process it returned the address '0x55ff09543000'. 

Next when it requests more heap memory, it passes that address as the argument to sys\_brk(address), and at this point the kernel validates that there are no memory overlaps, aligns the new brk address to PAGE\_SIZE(generally 4KB) and does some housekeeping.

If successful it returns the new end of heap address which in my case was '0x55ff09564000'. The dynamic memory requested by malloc will be in between the oldbrk and newbrk values(that is within the valid heap memory being tracked by the Kernel). As can be inferred, heaps grow upwards in memory, for x86 architecture. 

