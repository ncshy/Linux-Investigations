## Lockless Single Producer Single Consumer Queue

We will be discussing about the mechanism by which the XDP socket library and the Linux Kernel work together to move packets between the user-kernel boundary with no copies, and how it maintains a lockless access to this shared queue. <br>

The 2 queues of interest here are the FillQ and the RxQ.
The FillQ has the userspace as the producer and the Kernel as the consumer.
The RxQ has the Kernel as the producer and the userspace as the consumer.

We will go through the queue usage and mechanics step by step with the help of code blocks and diagrams. <br>

**We consider FillQ first**
# Step 1
![Alt text](spsc_1.png "Initial State")
```
In the Initial state, we have an empty FillQ denoted by free1 to free9. There is a consumer and producer pointer for this queue, reference by the term 'True ring state'.

Similarly there is the userspace local consumer and producer pointers known as 'cached_cons' (blue) and 'cached_prod' (green).
```

# Step 2
![Alt text](spsc_2.png "Producer for the FillQ")
```
The function xsk_ring_prod__reserve(fq) is used to move the cached_cons from 0 to cached_cons + queue_size. The relevance of this action will be understood at a later step.

static inline __u32 xsk_ring_prod__reserve(struct xsk_ring_prod *prod, __u32 nb, __u32 *idx)
{
        if (xsk_prod_nb_free(prod, nb) < nb)    # Check if atleast nb descriptors are free
                return 0;

        *idx = prod->cached_prod;
        prod->cached_prod += nb;	# Move cached_producer ahead by nb (queue size in this case).

        return nb;
}
```
Below is the definition for xsk\_prod\_nb\_free()

```C
static inline __u32 xsk_prod_nb_free(struct xsk_ring_prod *r, __u32 nb)
{
        static __u64 counter = 0;
        __u32 free_entries = r->cached_cons - r->cached_prod;

        if (free_entries >= nb)
                return free_entries;

        /* Refresh the local tail pointer.
         * cached_cons is r->size bigger than the real consumer pointer so
         * that this addition can be avoided in the more frequently
         * executed code that computs free_entries in the beginning of
         * this function. Without this optimization it whould have been
         * free_entries = r->cached_prod - r->cached_cons + r->size.
         */
        r->cached_cons = libbpf_smp_load_acquire(r->consumer);			# Updates cached_cons with true cons, which is 0 in this case
        r->cached_cons += r->size;						# Adds queue size to cached_cons

        if(counter == 0) {
                printf("In producer 2 r->cached_prod: %d; r->cached_cons: %d\n", r->cached_prod, r->cached_cons);
                counter++;
        }

        return r->cached_cons - r->cached_prod;					# Returns number of free descriptors which in this case is the size of the queue.
}


```
# Step 3

![Alt text](spsc_3.png "Fill addresses in the FillQ")

```C
xsk_ring_prod__fill_addr() is used to fill the FillQ descriptors with the correct UMEM frame addresses.

static inline __u64 *xsk_ring_prod__fill_addr(struct xsk_ring_prod *fill,
                                              __u32 idx)
{
        __u64 *addrs = (__u64 *)fill->ring;

        return &addrs[idx & fill->mask];		# Returns the descriptor address at each index
							# The returned address is dereferenced and set to the UMEM frame address.
}


```
The above image shows the state after the last part of xsk\_ring\_prod\_\_reserve and the whole of xsk\_ring\_prod\_\_fill\_addr have executed.At this juncture, the cached\_prod and cached\_cons have moved forward by the queue size and all the descriptors have entries in them.

# Step 4

![Alt text](spsc_4.png "Notify the kernel consumer")

```
xsk_ring_prod__submit() is used to do 2 important things:
1. Update the true prod pointer
2. Signal to the kernel that the FillQ is ready for consumption

static inline void xsk_ring_prod__submit(struct xsk_ring_prod *prod, __u32 nb)
{
        /* Make sure everything has been written to the ring before indicating
         * this to the kernel by writing the producer pointer.
         */
        libbpf_smp_store_release(prod->producer, *prod->producer + nb);
}

```
The libbpf\_smp\_store\_release macro is defined below:
```
# define libbpf_smp_store_release(p, v)                                 \
        do {                                                            \
                asm volatile("" : : : "memory");                        \ # The "memory" in the clobber field acts as a write memory barrier.
                __XSK_WRITE_ONCE(*p, v);                                \
        } while (0)

```

Now, it is the kernel's turn to consume the FillQ.

# Step 5

![Alt text](spsc_5.png "Kernel begins consumption INITIAL STATE")

The real 'cons' and 'prod' values of the FillQ have been updated based on the previous steps initiated by the user. <br>
The cached\_cons and cached\_prod variables of the kernel local state are both at 0 in the INITIAL STATE. <br>
The driver code invokes the function xp\_alloc() through the below call chain:

```
For Intel ice driver: drivers/net/ethernet/intel/ice/ice_base.c

int ice_vsi_cfg_rxq()
	--->  ice_alloc_rx_bufs_zc()
		---> xsk_buff_alloc()
			---> xp_alloc()
				---> __xp_alloc()
					---> xskq_cons_peek_addr_unchecked()

```
# Step 6

xskq\_cons\_peek\_addr\_unchecked is the important function which drives the access of the lockless FillQ forward. <br>

![Alt text](spsc_6.png "Kernel updates it's local cached pointers")
```C
static inline bool xskq_cons_peek_addr_unchecked(struct xsk_queue *q, u64 *addr)
{
        if (q->cached_prod == q->cached_cons)
                xskq_cons_get_entries(q);			# Updates true_cons with cached_cons value, which in this case is 0.
								# Updates cached_prod with true_prod value, which in this case is queue_size. 
        pr_debug("KERNEL: %s fillq->cached_prod: %d fillq->cached_cons: %d\n", __func__,
               q->cached_prod, q->cached_cons);
        return xskq_cons_read_addr_unchecked(q, addr);		# Consumes FillQ descriptor
}

```
# Step 7 and 8 
![Alt text](spsc_7.png "Kernel consumes the FillQ descriptors")
![Alt text](spsc_8.png "Kernel consumes the FillQ descriptors")

As mentioned above, in xskq\_cons\_peek\_addr\_unchecked(), the FillQ descriptor is accessed and the UMEM frame address is returned to the kernel. <br>
The kernel then obtains the DMA address of this returned virtual address, and fills in the HW descriptor of the Network card. <br>

# Step 9
![Alt text](spsc_9.png "Kernel updates the true FillQ cons pointer")

As mentioned earlier in 'Step 6', the xskq\_cons\_peek\_addr\_unchecked() calls xskq\_cons\_get\_entries(), which will update the true cons pointer with the cached cons value whenever cached\_prod == cached\_cons, and so the true cons value moves forward by queue\_size, and due to wrap around, the state of the FillQ is the same as Step 1.


