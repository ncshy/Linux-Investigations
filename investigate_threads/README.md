# Investigation of threads in Linux

```
$ ./threads

Main Thread process id is: 16895
Main Thread thread id is: 16895
Thread 1 process id is: 16895
Thread 1 thread id is: 16896
Thread 2 process id is: 16895
Thread 2 thread id is: 16897

```
As can be seen from the above logs, the main thread, Thread 1 and Thread 2 all share the same process ID, obtained from getpid(). <br>
However, I am also printing the thread id using gettid(), and this shows a unique value for each of the 3 threads. <br>

This can also be observed from the top command 
```
$ top -H -p 16895

    PID USER  PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND      
 16896  user  20   0   19032    632    548 R  66.4   0.0   0:15.40 threads                                                                                                                     
  16897 user  20   0   19032    632    548 R  65.8   0.0   0:15.35 threads                                                                                                                     
  16895 user  20   0   19032    632    548 S   0.0   0.0   0:00.00 threads         

```

-H is used to list all threads. <br>

# Now for the confusing part

How are the process id and thread id represented in the kernel? <br>

In the Kernel, each thread is treated as a unique process. This has scheduling advantages as each thread can be scheduled independent of each other. <br>
These unique processes also behave like threads, since their process memory space is a copy of each other, except for the local stack and the current instruction pointer. <br>

Knowing this, each process has a task\_struct that describes the process and all it's settings. The task\_struct has embedded within it, a uniqued ID called ProcessID(PID). <br>
But it also has another field embedded within it called Thread Group ID(TGID). What is TGID? <br>

TGID refers to the leader of the thread group. In a normal program, it starts with a main thread from which other threads are created. <br>
So, in this case the main thread is the thread group leader, and the TGID is set to it's PID. <br>

Which means from my example, TGID for main, thread1 and thread2 are all set to the PID of main, which happened to be 16895. <br>
PID on the other hand, was unique for each thread, and this represents the PID field, which was: <br>
main PID - 16895 <br>
thread1 PID - 16896 <br>
thread2 PID - 16897 <br>

From strace output:
```
clone(child_stack=0x7f8a84d95fb0, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tid=[16897], tls=0x7f8a84d96700, child_tidptr=0x7f8a84d969d0)
```
All lot of clone flags are set, this shows that threads share a lot in common with their parent. The most important field is the CLONE\_THREAD which sets the TGID to the parent's PID. <br>

So finally to recap, <br>
**getpid() returns the TGID of the process ; gettid() returns the PID of the process**

# Signal handling

The ways signals are routed to processes is based on the TGID. So if a SIGINT signal is received by thread1, it will affect all processes having the same TGID as thread1. <br>
Thus a SIGINT to thread1 will terminate all the 3 threads in the program. <br>
 
In the program code, I have also shown signal handling, where the default SIGINT operation(SIG\_DFL) is overwritten by the handler function handler(). <br>
The handler function just prints out a statement and resets the SIGINT back to SIG\_DFL. If it wasn't reset, it would keep printing a statement everytime SIGINT is triggered. <br>

There is a lot more to Signals, I will perhaps cover it another time. 


