# Investigating core dumps in Linux

While working with Linux kernel code, often due to some coding error, the kernel does a dump of all the registers and stack trace, which is referred to as an "OOPS message". <br>

While going through some signal documentation for code in user-space, I came across certain signals(SIGSEGV{segmentation faults}, SIGQUIT) which generate a core dump. I myself have written lots of code
that has failed with a SIGSEGV but I have never seen a core dump being generated. So I thought I would investigate how to obtain this core dump. <br>

I wrote the program in 'segfault.c' which basically dereferences a NULL pointer, thus receiving a SIGSEGV signal from the kernel. As expected, I did not see any core dump file even though the output was:
```
$ ./segfault
Segmentation fault (core dumped)
```
The output states the error and also mentions the core was dumped, but the question remains where? <br>

I looked at the kernel log files, and it mentions the segfault:
```
$ cat /var/log/kern.log | tail -20
[ 1589.399635] segfault[3985]: segfault at 0 ip 00005570cb205171 sp 00007ffc8e9dca10 error 4 in segfault[5570cb205000+1000]
[ 1589.399640] Code: ff ff f3 0f 1e fa 55 48 89 e5 48 83 ec 10 48 c7 45 f8 00 00 00 00 c7 45 f4 03 00 00 00 c7 45 f0 00 00 00 00 eb 13 48 8b 45 f8 <8b> 00 8d 14 00 48 8b 45 f8 89 10 83 45 f0 01 8b 45 f0 3b 45 f4 7c
```

It mentions the program and address that generated the segfault, but that was not good enough. I need a core file that can be used by a debugger such as gdb. <br>

So, I looked at the 'man page' for core and

# that lead me down the rabbit hole

```
$ man 5 core
By default, a core dump file is named core, but the /proc/sys/kernel/core_pattern file (since Linux 2.6 and 2.4.21) can be set to define a template that is used to name core dump files.
```
So there are a bunch of files that define where and the pattern of the name for the core file. <br>

When I checked it in my computer, I got:
```
$ cat /proc/sys/kernel/core_pattern 
|/usr/share/apport/apport %p %s %c %d %P %E
```
There was a user-space program mentioned in this output. So I went back to the man page for core:
```
$ man 5 core
Since kernel 2.6.19, Linux supports an alternate syntax for the /proc/sys/kernel/core_pattern file.  If the first character of this file is a pipe symbol (|), then the remainder of the line is interpreted as  the  com‐
mand-line for a user-space program (or script) that is to be executed.
```

Naturally, that led me to the python program /usr/share/apport/apport. Inside this program, there was the following line of code that evidently mentioned that on a SIGQUIT, a core dump is written. <br>
I would also like to mention this as an example of great function naming :
```
if signum == str(int(signal.SIGQUIT)):
        drop_privileges()
        write_user_coredump(pid, cwd, core_ulimit)
        sys.exit(0)

```
I rewrote the code in segfault.c to do an infinite while loop, while I passed the SIGQUIT signal using
```
$ kill -3 <PID> 
```
Here 3 is the signal number corresponding to SIGQUIT. <br>
The core file was finally generated in the same directory as my source code, however it was empty. <br>

I went back to the apport program and looked at the write\_user\_coredump function. Right at the beginning, I see:
```
# three cases:
# limit == 0: do not write anything
# limit < 0: unlimited, write out everything
# limit nonzero: crashed process' core size ulimit in bytes

if limit == 0:
        return

```
Sure enough, my program had a limit(which is the size of the core file defined by the source binary) set to 0, so the core file was empty. <br>

There was another man page relevant to the core limit and it was the getrlimit page.
```
$ man getrlimit
The getrlimit() and setrlimit() system calls get and set resource limits.  Each resource has an associated soft and hard limit, as defined by the rlimit structure:

           struct rlimit {
               rlim_t rlim_cur;  /* Soft limit */
               rlim_t rlim_max;  /* Hard limit (ceiling for rlim_cur) */
           };

```
This basically obtains a struct of the form mentioned above and I needed to change the value of rlim\_cur, which I set to about 500KB in the source code. <br>

Once I made this change, I was able to send a SIGQUIT to my running process, and generate a core dump file with content in it.
```
$ ./segfault
Quit (core dumped)

$ ls
core  segfault  segfault.c

$ file core
core: ELF 64-bit LSB core file, x86-64, version 1 (SYSV), SVR4-style, from './segfault', real uid: 1000, effective uid: 1000, real gid: 1000, effective gid: 1000, execfn: './segfault', platform: 'x86_64'

$ ll core
380928 Apr 12 23:30 core         --------> not empty anymore
```
From the file command, it can be seen that the core has a unique ELF header value than normal libraries or executables, which have the 'shared object' or 'executable' value. <br>

Finally using gdb, I could debug the core file by doing:
```
$ gdb segfault core
Reading symbols from segfault...
[New LWP 4306]
Core was generated by `./segfault'.
Program terminated with signal SIGQUIT, Quit.
#0  main () at segfault.c:19
19	    while(1)  {

```
Which gives a pretty detailed explanation of what happened and where. <br>
At this point, it was time to remove the while loop and get back to dereferencing NULL pointers. <br>
Before running the new binary, I had to remove the existing core file. <br>

The new core file was generated after a SIGSEGV signal and on debugging the core file
```
$ gdb segfault core
Reading symbols from segfault...
[New LWP 4371]
Core was generated by `./segfault'.
Program terminated with signal SIGSEGV, Segmentation fault.
#0  0x0000560365d8a220 in main () at segfault.c:21
21	        *val = *val + *val;

```
There we have the new reason for the core dump, segfault while dereferencing 'val' which is NULL. <br>
Finally, the reason I need to pass segfault binary to gdb even when diagnosing the core file is so that it can extract the symbols from it. Without the symbols, it wouldn't be able to give an accurate human readable format for the function names etc. <br>

So this was the story of the 'Core dump file' in user-space programs. 

