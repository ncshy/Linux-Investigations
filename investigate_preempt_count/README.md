# Investigating the PREEMPT\_COUNT variable

## Kernel pre-emption brief:
Linux supports Kernel preemption. As the name suggests, the current process can be pre-empted before completion by another task. <br>
Such an arrangement allows the system to be more dynamic. An example would be as follows: <br>

```
1) Process 1 initiates a disk read, and is blocked on the read call.

2) Process 2 gets scheduled and runs until it's time slice is complete

3) Process 3 is scheduled and an interrupt occurs, because the read has completed.
Upon handling the interrupt and returning from the interrupt, if preemption is enabled, the blocked process 1 can be rescheduled back on the CPU before Process 3 completes it's current sequence of operations.
```

**Now that we have an idea of kernel preemption, the question is how is it implemented ?** <br>

## Preempt count definition
The main variable to focus on is the preempt\_count variable, which is a 4 Byte field and is divided as follows:
```C
From include/linux/preempt.h

 *         PREEMPT_MASK:        0x000000ff
 *         SOFTIRQ_MASK:        0x0000ff00
 *         HARDIRQ_MASK:        0x000f0000
 *             NMI_MASK:        0x00f00000
 * PREEMPT_NEED_RESCHED:        0x80000000

``` 

The above shows that the least significant 8 bits are for preemption count, the next 8 bits(moving towards most significant) are for softirqs, the next 4 bits are for hard interrupts, the 4 bits beyond that are for non-maskable interrupts and the most significant bit is for a special case. <br>

When the preempt count field is 0, it means that:
- Kernel preemption is enabled
- No irqs are running
- No softirqs are running

## Useful MACROS to check current kernel context
Some of the helper macros make use of these properties to identify if the current kernel code is running in interrupt context, softirq context or in process context.

```C
# define softirq_count()        (preempt_count() & SOFTIRQ_MASK)
# define irq_count()            (preempt_count() & (NMI_MASK | HARDIRQ_MASK | SOFTIRQ_MASK))
# define nmi_count()     (preempt_count() & NMI_MASK)
# define hardirq_count() (preempt_count() & HARDIRQ_MASK)
------------------------------------------------------------------
# define in_nmi()                (nmi_count())
# define in_hardirq()            (hardirq_count())
# define in_task()              (!(preempt_count() & (NMI_MASK | HARDIRQ_MASK | SOFTIRQ_OFFSET)))
```
As can be seen if NMI, HARDIRQ and SOFTIRQ bits are all 0, then the in\_task() returns 1, and that implies that the kernel code is executing in process context.

## Enabling/Disabling preemption

By default kernel preemption is enabled allowing the kernel to be dynamic. However, there are sections of code where preemption is not desired. These include critical sections that are protected by locks. <br>
If a process acquires a lock, and then is preempted, we could end up with priority inversion, or simply a slower response time for processes contending for that same lock. <br>
As a result, in the kernel code, almost all lock-acquires implicitly disable preemption. <br>

For example:
```C
From include/linux/spinlock_api_smp.h

static inline void __raw_spin_lock(raw_spinlock_t *lock)
{
        preempt_disable();
        spin_acquire(&lock->dep_map, 0, 0, _RET_IP_);
        LOCK_CONTENDED(lock, do_raw_spin_trylock, do_raw_spin_lock);
}

```
The code for preempt\_disable() is as shown:
```C
#define preempt_disable() \
do { \  
        preempt_count_inc(); \
        barrier(); \
} while (0)
```
The above code, ensures the least significant 8 bits is non-zero, which means that preemption is disabled until it set to zero again. <br>  
