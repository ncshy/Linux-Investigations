# Investigating memory map of shared libraries and static libraries

## Code 

The primary purpose of the code, is to:
1) Obtain the process ID of itself
2) Construct a shell command "cat /proc/<pid>/maps"
3) Execute it.

# Shared libraries

The main difference in the output file comes based on the type of library linking I specify to gcc. 
The default option in gcc is to create a shared library. The output reflects this use case. 

On executing the binary, the following output is produced:
```
56086e418000-56086e419000 r--p 00000000 fd:01 26744513                   /home/user/program/hello_shared
56086e419000-56086e41a000 r-xp 00001000 fd:01 26744513                   /home/user/program/hello_shared
56086e41a000-56086e41b000 r--p 00002000 fd:01 26744513                   /home/user/program/hello_shared
56086e41b000-56086e41c000 r--p 00002000 fd:01 26744513                   /home/user/program/hello_shared
56086e41c000-56086e41d000 rw-p 00003000 fd:01 26744513                   /home/user/program/hello_shared
56086e770000-56086e791000 rw-p 00000000 00:00 0                          [heap]
7f8ca7c00000-7f8ca7c25000 r--p 00000000 fd:01 35655666                   /usr/lib/x86_64-linux-gnu/libc-2.31.so
7f8ca7c25000-7f8ca7d9d000 r-xp 00025000 fd:01 35655666                   /usr/lib/x86_64-linux-gnu/libc-2.31.so
7f8ca7d9d000-7f8ca7de7000 r--p 0019d000 fd:01 35655666                   /usr/lib/x86_64-linux-gnu/libc-2.31.so
7f8ca7de7000-7f8ca7de8000 ---p 001e7000 fd:01 35655666                   /usr/lib/x86_64-linux-gnu/libc-2.31.so
7f8ca7de8000-7f8ca7deb000 r--p 001e7000 fd:01 35655666                   /usr/lib/x86_64-linux-gnu/libc-2.31.so
7f8ca7deb000-7f8ca7dee000 rw-p 001ea000 fd:01 35655666                   /usr/lib/x86_64-linux-gnu/libc-2.31.so
7f8ca7dee000-7f8ca7df4000 rw-p 00000000 00:00 0 
7f8ca7e12000-7f8ca7e13000 r--p 00000000 fd:01 35655661                   /usr/lib/x86_64-linux-gnu/ld-2.31.so
7f8ca7e13000-7f8ca7e36000 r-xp 00001000 fd:01 35655661                   /usr/lib/x86_64-linux-gnu/ld-2.31.so
7f8ca7e36000-7f8ca7e3e000 r--p 00024000 fd:01 35655661                   /usr/lib/x86_64-linux-gnu/ld-2.31.so
7f8ca7e3f000-7f8ca7e40000 r--p 0002c000 fd:01 35655661                   /usr/lib/x86_64-linux-gnu/ld-2.31.so
7f8ca7e40000-7f8ca7e41000 rw-p 0002d000 fd:01 35655661                   /usr/lib/x86_64-linux-gnu/ld-2.31.so
7f8ca7e41000-7f8ca7e42000 rw-p 00000000 00:00 0 
7fffba833000-7fffba854000 rw-p 00000000 00:00 0                          [stack]
7fffba86a000-7fffba86d000 r--p 00000000 00:00 0                          [vvar]
7fffba86d000-7fffba86e000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 --xp 00000000 00:00 0                  [vsyscall]

```

The shared libraries get mapped into the process address space below the end of the stack(stack starts at a high address and grows downwards). 

The first library loaded in is the dynamic linker(ld-2.31.so), which will resolve all library dependencies, and map the relevant library code onto this process address space.

The library dependencies are checked and since this basic program relies only on the libc library, it loads that library into the process address space. 

The code, data, heap and stack segment for the binary are also loaded in along with specialized zones such as vdso, vsyscall etc. 

vdso is a mechanism by which, a special page is mapped to the process, this page contains low-level code which is run when a system call is initiated. 
The old system of using int 0x80 to trigger a system call was not optimal. So newer processors introduced optimal instructions to handle system calls. The vdso is called by the C Library.

vsyscall is a mechanism that did the same functionality as vdso on an x86 system, but in an x86-64 system, it's used to hold frequently accessed time related values. 

The size of the 'hello\_shared' binary file is 
```
$ ls -la hello_shared
-rwxrwxr-x 1 user user 18K May 14 21:40 hello_shared
```
# Static libraries

To create an output file with static libraries(that is, library code is pasted onto the program binary, thus creating a larger binary which requires no dependency on shared libraries), the gcc has to be given an additional compilation flag <bold>"--static"</bold>

On executing the binary, the following output is produced:
```
00400000-00401000 r--p 00000000 fd:01 26744512                           /home/user/program/hello_static
00401000-00497000 r-xp 00001000 fd:01 26744512                           /home/user/program/hello_static
00497000-004be000 r--p 00097000 fd:01 26744512                           /home/user/program/hello_static
004bf000-004c2000 r--p 000be000 fd:01 26744512                           /home/user/program/hello_static
004c2000-004c5000 rw-p 000c1000 fd:01 26744512                           /home/user/program/hello_static
004c5000-004c6000 rw-p 00000000 00:00 0 
023ad000-023d0000 rw-p 00000000 00:00 0                                  [heap]
7ffd0f819000-7ffd0f83a000 rw-p 00000000 00:00 0                          [stack]
7ffd0f98f000-7ffd0f992000 r--p 00000000 00:00 0                          [vvar]
7ffd0f992000-7ffd0f993000 r-xp 00000000 00:00 0                          [vdso]
ffffffffff600000-ffffffffff601000 --xp 00000000 00:00 0                  [vsyscall]

```
As can be observed, the layout is very different and much smaller. The only segments loaded in are the code, data, heap and stack of the binary 'hello\_static'. There are no explicit library files, this is because the library code is part of the binary itself. 

The advantage is that, this allows this binary to portable across systems. Additionally, there are no library dependencies to resolve during runtime, so it starts quicker. 

The disadvantage is the huge footprint of each binary. For example, if libc is 2MB in size, and I statically link it for 100 binaries, then if those 100 binaries are running concurrently on the system, the amount of memory reserved for libc would be 200MB. Whereas, in a shared library scenario, the footprint would only be 2MB for 1 or 100 binaries. 

It also enlarges the size of the binary program, which can be seen with:
```
$ ls -lh hello_static
-rwxrwxr-x 1 user user 865K May 14 21:55 hello_static
```
The 'hello_shared' binary was 18K in size, but the 'hello_static' binary is 865K in size, because it contains the vast code of the libc library. 

Linux encourages use of shared libraries, as it allows better use of physical memory and it makes efficient use of the Virtual memory system of the Linux Operating System.






