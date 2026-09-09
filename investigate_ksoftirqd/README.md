## How does a Kernel thread maintain the same semantics as a Softirq ?

The question is how does a kernel thread behave similar to a softirq even though the thread runs in process context, and the softirq runs in atomic context. 

# Brief definitions

**Softirq** : The non-urgent part of an interrupt handler. It runs in an atomic context, but importantly interrupts are enabled. <br>
The last point is important, because it allows the system to be reactive to external events.

**Kernel thread** : A process that can be scheduled by the scheduler. However, it has no userspace, and is meant purely for handling kernel code. It runs with a very low process priority.

**ksoftirqd/CPU** : A kernel thread that exists per CPU, and is tasked with running softirq code when the system asks it to.

# How is a softirq triggered ?

We will focus on the networking code to understand how a softirq is triggered.

The network driver interrupt handler invokes napi\_schedule() when a packet is successfully received by the network device. <br>
The code snippet below shows the call for an Intel ixgbe driver. <br>

```C
static irqreturn_t ixgbe_intr(int irq, void *data)		// Device interrupt handler
{
	...
	...
	napi_schedule_irqoff(&q_vector->napi);
	...
}

```
The above call happens in a hard interrupt context with all interrupts on this CPU disabled. 

The napi\_schedule\_irqoff ends up calling an internal function as shown below:
```
	napi_schedule_irqoff()
		---> __napi_schedule_irqoff()
			---> ____napi_schedule_irqoff()
				---> ____napi_schedule()
```

This function has the following definition:
```C
static inline void ____napi_schedule(struct softnet_data *sd,
                                     struct napi_struct *napi)
{
	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
}
```
NET\_RX\_SOFTIRQ is the Softirq dealing with processing incoming packets and the above call to \_\_raise\_softirq\_irqoff() will set the pending bit in the Per-CPU local softirq pending data structure. 

```C
void __raise_softirq_irqoff(unsigned int nr)
{
        lockdep_assert_irqs_disabled();
        trace_softirq_raise(nr);
        or_softirq_pending(1UL << nr);		// Sets the NET_RX_SOFTIRQ bit in the local_softirq_pending data strucure
}

```
The above section covers how a NET\_RX\_SOFTIRQ(one of the softirqs) is triggered in the first place. 

#TO BE CONTINUED
 
