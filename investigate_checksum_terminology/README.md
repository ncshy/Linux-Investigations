<h2> Investigate Linux checksum terminology </h2>

While traversing the Linux kernel code, especially when dealing with network devices, we come across specific fields of the form CHECKSUM\_XXX.

These are in the broad sense, a means for the driver/HW to communicate with the software network stack, regarding checksums.

The following statements are based on the Linux Kernel 5.15.184 kernel

The CHECKSUM\_XXX fields are defined in the file include/linux/skbuff.h

```
#define CHECKSUM_NONE		0
#define CHECKSUM_UNNECESSARY	1
#define CHECKSUM_COMPLETE	2
#define CHECKSUM_PARTIAL	3

```

<h3> What does each field mean? </h3>

The simplest field to understand is CHECKSUM\_NONE. On the Receive side, if the skb-\>ip\_summed field is set to CHECKSUM\_NONE, it implies one of 3 things:

1. The Hardware device is not capable of calculating checksums for the relevant network protocol.
2. The software has mangled the packet during it's packet processing, and now the checksum has to be recalculated on the network stack.
3. The Hardware has calculated the checksum, but has deemed an error has occured, and so the software has to deal with the recalculation.

The next 2 fields are a bit more trickier, since their difference is very subtle.
CHECKSUM\_COMPLETE implies that the hardware is fully capable of calculating the checksum, passing the checksum value (without the pseudo header value) to it's associated device driver, so that the skb-\>csum field can be updated. Later on, the network stack validates the checksum by adding the pseudo header checksum to the HW provided checksum. 

CHECKSUM\_UNNECESSARY on the other hand states that the hardware has validated the checksum, and found no errors, however the skb-\>csum field has not been updated. The network stack can avoid the validation in this case. The best example of the difference between the above two fields is shown below:
```
include/linux/skbuff.h  (line 4256)

#define __skb_checksum_validate(skb, proto, complete,                   \
                                zero_okay, check, compute_pseudo)       \
({                                                                      \
        __sum16 __ret = 0;                                              \
        skb->csum_valid = 0;                                            \
        if (__skb_checksum_validate_needed(skb, zero_okay, check))      \	//Avoid validation if CHECKSUM_UNNECESSARY
                __ret = __skb_checksum_validate_complete(skb,           \
                                complete, compute_pseudo(skb, proto));  \
        __ret;                                                          \
}) 
```

An example of CHECKSUM\_COMPLETE can be found in:
``
drivers/net/ethernet/mellanox/mlx4/en_rx.c ---> The driver reads the checksum value and updates the skb->csum field
```

An example of CHECKSUM\_UNNECESSARY can be found in:
```
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  --> CHECKSUM_UNNECESSARY set if packet is TCP/UDP or SCTP, whose checksum validation is supported on Intel 82599 NICs.
```

CHECKSUM\_PARTIAL on the other hand, has more use on the Tx side of network data transmission. Here during a Hardware checksum offload, the software stack calculates only the pseudo header checksum, and passes this data to the driver. The driver in turn sets up the required offload context for the device, while passing the **partial** checksum. During this operation, the network stack sets the skb->ip_summed field is set to CHECKSUM\_PARTIAL. Note, that the direction of messaging is different. It is the software stack informing the driver that only a partial checksum has been calculated for this packet. The rest has to be calculated by the hardware device, or the network driver itself.

An example of CHECKSUM\_PARTIAL can be found in:
```
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c (Line num 8068) --> There is a check that CHECKSUM_PARTIAL is set, before the driver sets up the transmit context for the hardware device.
```

More information can be found in [Checksum Offloads](https://www.kernel.org/doc/html/latest/networking/checksum-offloads.html) , although this documentation is not very easy to make sense of.  
 
