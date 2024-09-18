# RPS implementation in Linux #

## What is RPS? ##

For high performance networking, per packet processing in the CPU needs to be very fast. One important way of achieving this when the CPU speed is fixed, is through parallel processing of packets. i.e, Dividing a set of packets into subsets and processing each subset on a CPU core. Since it is dealing with fewer packets, there is more time available for per packet processing <br>
Most modern NICs have multiple queues on network port to receive and transmit packets, and each queue can be assigned to a CPU core. In effect generally, if a packet hits queue0, it is processed by core0; queue1 by core1 etc. <br>
Therefore the queues act as our subset and the mechanism to divide the set of packets into subsets is done by moving packets into each of these queues. This is called Receive Side Scalingg (RSS) and is done in the NIC hardware. However, not all NICs might support RSS, and thus the implementation of this same idea on the software is called Receive Packet Steering (RPS). <br>

## How is RPS implemented in the Linux Kernel ##

### Background info ###

An important data structure is softnet_data. Below are few fields imporant for this discussion
```
struct softnet_data {			# Per-CPU data structure
	poll_list;			
	backlog_dev;			
	input_pkt_queue			
};			

```

NAPI devices (devices that use polling over per packet interrupts) use poll_list <br>
During interrupt context (i.e, when the packet received on the NIC has been DMA'ed into system memory), then the NAPI capable device interface is added to the list. <br>
During the softirq context, the poll_list is traversed, and each device on the list has a napi_poll_func, which is invoked. <br>
This napi poll function of the device processes all the packets in the queue until a certain time or packet limit has been reached. <br> 

Non-NAPI devices (that use per packet interrupts) add packets to a fictitious device called the backlog device. This device has a queue (input_pkt_queue) which holds packets from all such devices/queues. <br>

### Getting to the RPS implementation ###

For NAPI devices, inside the napi poll function, the skb (packet metadata + buffer) is created and netif_receive_skb() is invoked. <br>

netif_receive_skb() is a multi stage function which includes RPS cpu selection and Generic XDP implementation before handing the packet to L3 layer. <br>
If RPS is enabled, RPS cpu selection logic is run and the packet is added to the selected CPU’s softnet data structure’s backlog_dev field; after which the function call exits. <br>

```
Legend:
--> Implies that above function calls the function on this line

netif_receive_skb()	
-->	netif_receive_skb_internal(skb) {
		...

		#ifdef CONFIG_RPS
		    if (static_branch_unlikely(&rps_needed)) {
		        struct rps_dev_flow voidflow, *rflow = &voidflow;
		        int cpu = get_rps_cpu(skb->dev, skb, &rflow);		# Cpu is selected based on the flow
		
		        if (cpu >= 0) {
		            ret = enqueue_to_backlog(skb, cpu, &rflow->last_qtail);		# Packet is added to the backlog device's input_pkt_queue on the selected CPU
		            rcu_read_unlock();
		            return ret;
		        }
		    }
		#endif

		...
	}

```

Now when the selected CPU's softirq context is in effect, the backlog device's input_pkt_queue is traversed and each packet is further processed on that selected CPU, thus effectively achieving the end goal of splitting the set of packets into subsets across multiple CPU cores. <br>

As a final note, for non-NAPI devices using RPS, netif_rx is invoked during interrupt context and it can select the RPS cpu and add it to the backlog_dev; which is then run later, in softirq context. <br>

```
Legend:
--> Implies that above function calls the function on this line

netif_rx(struct sk_buff *skb)		
-->	netif_rx_internal(skb) {
		...

		#ifdef CONFIG_RPS
		    if (static_branch_unlikely(&rps_needed)) {
		        struct rps_dev_flow voidflow, *rflow = &voidflow;
		        int cpu;
		
		        rcu_read_lock();
		
		        cpu = get_rps_cpu(skb->dev, skb, &rflow);	# Cpu is selected based on the flow
		        if (cpu < 0)
		            cpu = smp_processor_id();
		
		        ret = enqueue_to_backlog(skb, cpu, &rflow->last_qtail); # Packet is added to the backlog device's input_pkt_queue on the selected CPU
		
		        rcu_read_unlock();
		    } else
		#endif

		...
	}	

```

