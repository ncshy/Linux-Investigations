# Investigation of Linux Copy on Write

Copy on Write is an efficient optimization in the Linux kernel to increase the speed of creating new processes and executing new programs, by greatly reducing memory copies and accesses, while maintaining correct behaviour created by the process abstraction. <br>

The C program works the following way: <br>
1. Define a variable 'a'. 
2. creates a child process
3. Parent waits for child to exit
4. Child process modifies it's copy of the variable 'a'.
5. Child exits
6. Parent prints it's value of 'a'
7. Parent exits

What we observe from the output is that the child's value of 'a' is different from the parent's value of 'a' , even though both of them have the same virtual address within their respective address space. <br>
```
a child: 8
a child address: 0x7ffe152c89f8
a parent: 10
a parent address: 0x7ffe152c89f8
```

Linux's COW creates a duplicate of the parents' address space and page table entries and marks the page frames as non-writable. <br>

The strace output when the parent creates the child is show below : <br>
```
clone(child_stack=NULL, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0x7fdd4f6a2810) = 1663696
```
When the child process modifies the page frame, a page fault occurs identifying the condition as COW . At this point the old page frame is copied to a new page frame and the child's page table is updated accordingly. <br>

The stack trace when this event occurs is shown below. The child's thread-id (analogous to PID value in user-space) is 1663696. <br>
We see through the trace that for this child process, the page copy is eventually invoked via a \_handle_mm_fault which invokes handle_pte_fault. <br>

```
$ sudo bpftrace -e 'k:wp_page_copy /tid==1663696/ {printf("%s", kstack);}'
Attaching 1 probe...

        wp_page_copy+1
        __handle_mm_fault+2069
        handle_mm_fault+216
        do_user_addr_fault+450
        exc_page_fault+119
        asm_exc_page_fault+39
```

The strace of the child process upon exit and it's signal reaching the parent is shown below. It shows the signal number, the signal code and the child thread id. <br>
```
 SIGCHLD {si_signo=SIGCHLD, si_code=CLD_EXITED, si_pid=1663696, si_uid=1001, si_status=0, si_utime=0, si_stime=0}
```

In the end, When the parent multiplies 'a' with 2 the value of 'a' retrieved is the original value, since it is still referring to the old page frame. <br>



