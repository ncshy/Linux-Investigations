# Linux-Investigations
Projects to explore internal workings of Linux systems

## Network specific
**investigate_vxlan** : Setup a VXLAN communication and explore the packet structure <br> 
**investigate_tcpcksum_offload** : Understand how TCP/UDP/IP hardware checksum offload is enabled by a network device driver<br>
**investigate_ReceivePacketSteering** : Explore how a parallel processing concept is implemented in Linux <br>
**investigate_VlanStripping** : Explore how the driver works with the hardware to obtain VLAN tag information after a VLAN strip operation <br>
**investigate_Promiscuous_mode** : Explore how a packet capture program instructs the hardware to allow for listening on all frames on the wire. <br>

## Memory specific
**investigate_malloc** : Explores how malloc works and what happens at the system level. <br>
**investigate_mmap** : Explores how to use mmap() call and how it works generally. <br>
**investigate_coredumps** : Observing how to generate and use core dumps for user space programs. <br> 
**investigate_cow** : Exploring the Copy on Write mechanism in action <br> 

## System specific
**investigate_stack_x86_64** : Explores how the program stack is used during a function call and return on an x86\_64 architecture <br>
**investigate_stack_arm32** : Explores how the program stack is used during a function call and return on an ARM 32-bit architecture <br>
**investigate_stack_arm64** : Explores how the program stack is used during a function call and return on an ARM 64-bit architecture <br>
**investigate_threads** : Observing how threads are represented in the kernel and the effect of signals on them. <br> 
**investigate_staticlibs** : Exploring the difference in memory map of a program that is statically and dynamically linked. <br> 
**investigate_ioctl** : Exploring how the ioctl call is used and the kernel stack trace for 2 codes, one handled by the kernel, and the other handled by the network device driver. <br> 

## Code specific
**investigate_macros** : Explores the difference between macro,inline and regular functions. <br>
**investigate_recursive_macros** : Explore if C macros can be used to create infinite recursions. <br>
**investigate_bitfield_space** : Explore how much space in memory a 'C' bitfield implementation takes<br>

## Assembly/C
**understanding_C** : Using Assembly to understand the C language implementation <br>
**understanding_assembly** : Understanding Assembly language in general <br>
