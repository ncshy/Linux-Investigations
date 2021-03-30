# Investigation of VXLAN 

To setup the VXLAN connection, I am using 2 hosts on the same subnet. <br>
```
On Host 1(IP address - 192.168.0.4):
sudo ip link add vxlanif type vxlan id 20 dev eth0 remote 192.168.0.100 dstport 4789
sudo ip link addr add 192.168.10.2/24 dev vxlanif
sudo ip link set dev vxlanif up

On Host 2(IP address - 192.168.0.100):
sudo ip link add vxlan20 type vxlan id 20 dev eth0 remote 192.168.0.4 dstport 4789
sudo ip link addr add 192.168.10.14/24 dev vxlan20
sudo ip link set dev vxlan20 up

```
The above steps create a VXLAN interface called vxlanif on Host 1. The VID for this interface is 20. It will use eth0 physical interface to send packets on the wire to a host with remote IP address of 192.168.0.100. <br>
The interface vxlanif is provided a static IP address of 192.168.10.2 <br>

The same is done for Host 2, to create a VXLAN interface called vxlan20 which will send packets to remote host 192.168.0.4. <br>
The interface vxlan20 is provided a static IP address of 192.168.10.14 <br>

The result of sending a ping request is shown below. 
```
# sudo tcpdump -XXX -ne -i eth0 -Q out dst 192.168.0.100 

21:20:37.643200 2c:f0:5d:5e:8e:62 > 58:96:1d:10:85:bf, ethertype IPv4 (0x0800), length 148: 192.168.0.4.41467 > 192.168.0.100.4789: VXLAN, flags [I] (0x08), vni 20
5e:a0:1c:f1:42:26 > de:49:25:dd:70:85, ethertype IPv4 (0x0800), length 98: 192.168.10.2 > 192.168.10.14: ICMP echo request, id 22, seq 2, length 64
	0x0000:  5896 1d10 85bf 2cf0 5d5e 8e62 0800 4500  X.....,.]^.b..E.
	0x0010:  0086 0dee 0000 4011 eb1f c0a8 0004 c0a8  ......@.........
	0x0020:  0064 a1fb 12b5 0072 81dd 0800 0000 0000  .d.....r........
	0x0030:  1400 de49 25dd 7085 5ea0 1cf1 4226 0800  ...I%.p.^...B&..
	0x0040:  4500 0054 3a96 4000 4001 6ab2 c0a8 0a02  E..T:.@.@.j.....
	0x0050:  c0a8 0a0e 0800 860a 0016 0002 e5d9 5f60  .............._`
	0x0060:  0000 0000 64d0 0900 0000 0000 1011 1213  ....d...........
	0x0070:  1415 1617 1819 1a1b 1c1d 1e1f 2021 2223  .............!"#
	0x0080:  2425 2627 2829 2a2b 2c2d 2e2f 3031 3233  $%&'()*+,-./0123
	0x0090:  3435 3637                                4567

              --------------------------------------------                                     --------------------------------------------
	0x0000:  |5896 1d10 85bf | 2cf0 5d5e 8e62 | 0800 | 4500                          0x0000:  | DST MAC | SRC MAC | EtherType |  IP HDR   |
              ---------------------------------------------                                    --------------------------------------------
	0x0010:  0086 0dee 0000 4011 eb1f c0a8 0004 c0a8                                 0x0010:  |               IP HDR                      |
              --------------------------------------------                                     --------------------------------------------
	0x0020:  0064| a1fb 12b5 0072 81dd | 0800 0000 0000                              0x0020:  | IP HDR  |    UDP HDR   |    VXLAN HDR     |
              ---------------------------------------------                                    --------------------------------------------
	0x0030:  1400 |de49 25dd 7085| 5ea0 1cf1 4226 | 0800 |                           0x0030:  |  VXLAN HDR | DST MAC | SRC MAC  | EtherType|
             ----------------------------------------------                                   ---------------------------------------------
	0x0040:  4500 0054 3a96 4000 4001 6ab2 c0a8 0a02                                 0x0040:  |              IP HDR                       |
             ---------------------------------------------                                    ---------------------------------------------
	0x0050:  c0a8  0a0e | 0800 860a| 0016 0002 e5d9 5f60                             0x0050:  | IP HDR |    ICMP HDR   |   ICMP DATA      |
             ---------------------------------------------                                    ---------------------------------------------
	0x0060:  0000 0000 64d0 0900 0000 0000 1011 1213                                 0x0060:  |             ICMP DATA                     |
             --------------------------------------------                                     --------------------------------------------
	0x0070:  1415 1617 1819 1a1b 1c1d 1e1f 2021 2223                                 0x0070:  |             ICMP DATA                     |
             --------------------------------------------                                     --------------------------------------------
	0x0080:  2425 2627 2829 2a2b 2c2d 2e2f 3031 3233                                 0x0080:  |             ICMP DATA                     |
             --------------------------------------------                                     --------------------------------------------
	0x0090:  3435 3637                                                               0x0090:  |             ICMP DATA                     |

```
The best way to understand this packet is from the bottom up. 

There is an ICMP Payload (ICMP Data) and ICMP header that is encapsulated inside an IP payload. This IP refers to the packet from 192.168.10.2 > 192.168.10.14 , that is the communication between the 2 vxlan interfaces. <br>
This entire ICMP packet(including IP headers and Ethernet headers) is thus the VXLAN payload and as such a VXLAN header is attached onto this packet. <br>
The VXLAN packet is in turn embedded into an outer packet that uses a UDP connection. The UDP payload is this VXLAN packet and it has it's UDP header and IP layer that refers to the transmission from 192.168.0.4:<some port> > 192.168.0.100:4789 <br>

On the receiving end, the interface with MAC address 58:96:1d:10:85:bf and IP 192.168.0.100 receives the packet, removes the outer Ethernet and IP headers and passes the packet upward to the UDP port 4789. <br>
The UDP payload is then sent to VXLAN interface(vxlan20) with VXLAN id 20(information embedded within the VXLAN HDR). <br>
This interface than strips the inner Ethernet headers and IP headers and passes it to the kernel for ICMP processing. <br>

So in effect 2 interfaces(vxlanif and vxlan20) on the same subnet(192.168.10.0/24) are created on top of an L3 connection between 2 hosts(192.168.0.4 and 192.168.0.100). <br>
In my example the 2 underlying hosts were on the same subnet, but this does not have to be the case. The L3 connection could be between 2 hosts on completely different networks, yet still having the 2 vxlan interfaces on the same subnet. <br>
This in effect creates the effect from the perspective of the VXLAN interfaces as if they are physically connected at Layer 2. <br>
Thus vxlan creates a Logical L2 connection on top of a physical L3 connection. In other words an L2 over L3 network. 
