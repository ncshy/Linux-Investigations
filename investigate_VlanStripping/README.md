# VLAN stripping on the Receive side 

## Driver RX code flow for 82599 NIC

As part of the NAPI rx poll function, the following function is invoked
```
static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
			       struct ixgbe_ring *rx_ring,
			       const int budget)
{
	...
	...
	/* Create skb to hold data */
	...

	/* populate checksum, timestamp, VLAN, and protocol */
	ixgbe_process_skb_fields(rx_ring, rx_desc, skb);         <-- Function of interest
	
	...
}
```

Let's look at ixgbe_process_skb_fields function
```
void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
			      union ixgbe_adv_rx_desc *rx_desc,
			      struct sk_buff *skb)
{
	...

	if ((dev->features & NETIF_F_HW_VLAN_CTAG_RX) &&		<--- Check if VLAN strip offloading is advertised
	    ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_VP)) {   <--- Check the writeback descriptor's Status fields, to find if this is a VLAN packet and if it has been stripped
		u16 vid = le16_to_cpu(rx_desc->wb.upper.vlan);			<--- Obtain the vlan tag from the writeback descriptor
		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);	<--- Update skb metadata with the VLAN tag information
	}
	...

}
```

Looking deeper into the skb update function
```
static inline void __vlan_hwaccel_put_tag(struct sk_buff *skb,
					  __be16 vlan_proto, u16 vlan_tci)
{
	skb->vlan_proto = vlan_proto;
	skb->vlan_tci = vlan_tci;		<---  VLAN tag information is added to the skb metadata
}
```

## Understanding the RX write back descriptor representation in the driver code:

First the representation of the Advanced write back descriptor from the Intel 82599 Datasheet
[82599_Advanced_Recv_writeback_desc](82599_Advanced_recv_wb_desc.png) <br>

Now, the driver code representation: 
```
/* Receive Descriptor - Advanced */
union ixgbe_adv_rx_desc {		<-- Union of 16B 
	struct {
		__le64 pkt_addr; /* Packet buffer address */
		__le64 hdr_addr; /* Header buffer address */
	} read;
	struct {
		struct {
			union {
				__le32 data;
				struct {
					__le16 pkt_info; /* RSS, Pkt type */
					__le16 hdr_info; /* Splithdr, hdrlen */
				} hs_rss;
			} lo_dword;
			union {
				__le32 rss; /* RSS Hash */
				struct {
					__le16 ip_id; /* IP id */
					__le16 csum; /* Packet Checksum */
				} csum_ip;
			} hi_dword;
		} lower;
		struct {
			__le32 status_error; /* ext status/error */
			__le16 length; /* Packet length */
			__le16 vlan; /* VLAN tag */
		} upper;
	} wb;  /* writeback */   	<---Structure Of interest
};
```


