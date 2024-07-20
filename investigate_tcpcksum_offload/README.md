
# Explain the process of L3/L4 header checksum offload on an Intel 82599 NIC

First, we need to understand 2 important type of packet descriptors: <br>
1. Advanced transmit context descriptor
2. Advanced transmit data descriptor

## Advanced Context descriptor

This is a 16B descriptor. When a checksum offload should be done by the NIC hardware, this descriptor provides context about the operations to be performed and any additional directions if needed. <br>

[!alt text](adv_ctxt_desc.png)

### Important fields:

TUCMD - 11 bit field <br>
TUCMD.IPV4 - 2nd bit <br>
1. If 0, it indicates IPv6 is L3
2. If 1, it indicates IPv4 is L3
TUCMD.L4T - 3rd and 4th bit representing L4 <br>
1. 00 - UDP 
2. 01 - TCP
3. 10 - SCTP
4. 11 - Reserved

DTYP - 4 bit field ; Defines the type of descriptor <br>
1. Always 0x2 for Advanced transmit context descriptor

DEXT - 1 bit field; Set to 1 for advanced descriptor format
## Advanced Transmit descriptor

This is a 16B descriptor. The first 8B hold the Bus address of the packet to be DMA'ed from system memory to NIC internal buffer. <br>
The second 8B has a special meaning.

[!alt text](adv_tx_data_desc.png)

### Important fields 

1. DTALEN - 16 bit field, holds packet length 
2. DTYP - 4 bit field, always 0x3 for advanced transmit data descriptor
3. DCMD - 8 bit field
	1. TSE (bit 7) - If 0, then only header checksums should be calculated by the hardware
	2. DEXT (bit 5) - If 1, indicates advanced descriptor format
	3. IFCS (bit 1) - Set to 1, if header checksum should be calculated by the hardware
4. POPTS - 6 bit field; Checksums are calculated per packet, and enabled in this field of the data descriptor
	1. TXSM (bit 1) - If 1, L4 checksum should be calculated by HW.
	2. IXSM (bit 0) - If 1, L3 checksum should be calculated by HW (does not support IPv6).

## Following ixgbe driver code on the transmit direction

The transmit function of the ixgbe driver is ixgbe_xmit_frame <br>

```
ixgbe_xmit_frame()
	__ixgbe_xmit_frame() --> This function obtains the ring descriptor for a specific Tx queue (Each Tx queue has it's own Tx ring descriptor)
		ixgbe_xmit_frame_ring()
```

Let's look closer at ixgbe_xmit_frame_ring function, by highlighting the important lines of code: <br>

```
netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
			  struct ixgbe_adapter *adapter,
			  struct ixgbe_ring *tx_ring)
{
	struct ixgbe_tx_buffer *first;		--> Will hold the pointer to the packet to be transmitted
...
	first = &tx_ring->tx_buffer_info[tx_ring->next_to_use];
	first->skb = skb;					--> Ptr to packet to be transmitted
	first->bytecount = skb->len;		--> Total length of packet
...
	/* Check is segmentation offload is enabled */
	tso = ixgbe_tso(tx_ring, first, &hdr_len, &ipsec_tx);
	if (tso < 0)
		goto out_drop;
	else if (!tso)     					--> If no, then only checksums need to be calculated
		ixgbe_tx_csum(tx_ring, first, &ipsec_tx);
}

```

Let's investigate the ixgbe_tx_csum function <br>

```
static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
			  struct ixgbe_tx_buffer *first,
			  struct ixgbe_ipsec_tx_data *itd)
{
	switch (skb->csum_offset) {
		case offsetof(struct tcphdr, check):
			type_tucmd = IXGBE_ADVTXD_TUCMD_L4T_TCP;    --> Sets the TUCMD.L4T bit to 0x1
			fallthrough;
		case offsetof(struct udphdr, check):
			break;
	}

	ixgbe_tx_ctxtdesc(tx_ring, vlan_macip_lens, fceof_saidx, type_tucmd, 0);   --> Create the advanced context descriptor
}

```

Moving onto ixgbe_tx_ctxtdesc function <br>

```
void ixgbe_tx_ctxtdesc(struct ixgbe_ring *tx_ring, u32 vlan_macip_lens,
		       u32 fceof_saidx, u32 type_tucmd, u32 mss_l4len_idx)
{
	struct ixgbe_adv_tx_context_desc *context_desc;		--> Hold the context descriptor
	u16 i = tx_ring->next_to_use;						--> Current index in the ring to write to

	context_desc = IXGBE_TX_CTXTDESC(tx_ring, i);		--> Obtain 16B advanced descriptor from the current index

	i++;
	tx_ring->next_to_use = (i < tx_ring->count) ? i : 0;	--> Update current index by 1

	/* set bits to identify this as an advanced context descriptor */
	type_tucmd |= IXGBE_TXD_CMD_DEXT | IXGBE_ADVTXD_DTYP_CTXT;		--> Set DTYP to 0x2 and DEXT to 0x1 

	context_desc->type_tucmd_mlhl	= cpu_to_le32(type_tucmd);		--> Set descriptor flags
}
```
Now that the context descriptor has been set, and the current index has been updated, the HW will DMA this descriptor into it's memory at some point.

The function call returns back to ixgbe_xmit_frame_ring 

```
...
	else if (!tso)
		ixgbe_tx_csum(tx_ring, first, &ipsec_tx);		--> Returns from this function call
	
	if (ixgbe_tx_map(tx_ring, first, hdr_len))			--> Function call to fill up transmit data descriptor
		goto cleanup_tx_timestamp;

	return NETDEV_TX_OK;

```

We will check the last important function , ixgbe_tx_map <br>

```
static int ixgbe_tx_map(struct ixgbe_ring *tx_ring,
			struct ixgbe_tx_buffer *first,
			const u8 hdr_len)
{
	struct sk_buff *skb = first->skb;
	struct ixgbe_tx_buffer *tx_buffer;
	union ixgbe_adv_tx_desc *tx_desc;

	size = skb_headlen(skb);	--> Returns total packet size, for non SKB scattered packets
	data_len = skb->data_len;	--> data_len is 0 for non SKB scattered packets

	dma = dma_map_single(tx_ring->dev, skb->data, size, DMA_TO_DEVICE);		--> Map the data buffer to a DMA address, and set the transfer direction from Host to NIC device
	
	/* set the timestamp */
	first->time_stamp = jiffies;

	skb_tx_timestamp(skb);		--> Register the transmit time of the last transmitted packet

	i++;							
	if (i == tx_ring->count)
		i = 0;

	tx_ring->next_to_use = i;	--> Update current index of descriptor ring

}
```
At this point, both the context descriptor and transmit data descriptor have been filled, after the packet data buffer has been mapped to DMA memory and control of the packet handed to hardware.
The hardware will conduct the hardware checksum offloads on the packet based on the information provided in the context_desc.

Below are the important data structures referenced in the driver code <br>
```
struct ixgbe_ring {
	struct ixgbe_ring *next;	/* pointer to next ring in q_vector */
	struct ixgbe_q_vector *q_vector; /* backpointer to host q_vector */
	struct net_device *netdev;	/* netdev ring belongs to */
	struct bpf_prog *xdp_prog;
	struct device *dev;		/* device for DMA mapping */
	void *desc;			/* descriptor ring memory */
	union {
		struct ixgbe_tx_buffer *tx_buffer_info;
		struct ixgbe_rx_buffer *rx_buffer_info;
	};
	unsigned long state;
	u8 __iomem *tail;
	dma_addr_t dma;			/* phys. address of descriptor ring */
	unsigned int size;		/* length in bytes */

	u16 count;			/* amount of descriptors */

	u8 queue_index; /* needed for multiqueue queue management */
	u8 reg_idx;			/* holds the special value that gets
					 * the hardware register offset
					 * associated with this ring, which is
					 * different for DCB and RSS modes
					 */
	u16 next_to_use;
	u16 next_to_clean;

	unsigned long last_rx_timestamp;
...
}

/* Context descriptors */
struct ixgbe_adv_tx_context_desc {
	__le32 vlan_macip_lens;
	__le32 fceof_saidx;
	__le32 type_tucmd_mlhl;
	__le32 mss_l4len_idx;
};

/* Transmit Descriptor - Advanced */
union ixgbe_adv_tx_desc {
	struct {
		__le64 buffer_addr;      /* Address of descriptor's data buf */
		__le32 cmd_type_len;
		__le32 olinfo_status;
	} read;
	struct {
		__le64 rsvd;       /* Reserved */
		__le32 nxtseq_seed;
		__le32 status;
	} wb;
};

/* wrapper around a pointer to a socket buffer,
 * so a DMA handle can be stored along with the buffer */
struct ixgbe_tx_buffer {
	union ixgbe_adv_tx_desc *next_to_watch;
	unsigned long time_stamp;
	union {
		struct sk_buff *skb;
		struct xdp_frame *xdpf;
	};
	unsigned int bytecount;
	unsigned short gso_segs;
	__be16 protocol;
	DEFINE_DMA_UNMAP_ADDR(dma);
	DEFINE_DMA_UNMAP_LEN(len);
	u32 tx_flags;
};
```


