# Investigate how promiscuous mode is set on the network card

## Invoking tcpdump 
```
$ sudo tcpdump -ne -i enp0s25 -c 10 		<-- Listen on interface enp0s25 upto 10 packets
```
The interface 'enp0s25', is a port of the Intel Ethernet Connection I217 NIC. It uses the e1000e network driver <br>

## Using bpftrace to obtain stack trace for tcpdump
```
$ sudo bpftrace -e 'k:e1000e_set_rx_mode {printf("%s", kstack)}'

		e1000e_set_rx_mode+1
        dev_set_rx_mode+50
        dev_set_promiscuity+73
        packet_dev_mc+33
        packet_setsockopt+3255
        __sys_setsockopt+220
        __x64_sys_setsockopt+37
        x64_sys_call+7995
        do_syscall_64+84
        entry_SYSCALL_64_after_hwframe+103
```

## Exiting tcpdump
```
        e1000e_set_rx_mode+1
        dev_set_rx_mode+50
        dev_set_promiscuity+73
        packet_dev_mc+33
        packet_release+354
        __sock_release+66
        sock_close+21
        __fput+159
        ____fput+14
        task_work_run+112
        exit_to_user_mode_prepare+438
        syscall_exit_to_user_mode+39
        do_syscall_64+97
        entry_SYSCALL_64_after_hwframe+103

```
## Exploring the stack trace upto ndo_set_rx_mode
```
TBD IN part2

```

## Understanding what happens in ndo_set_rx_mode
This is the function that is invoked in the driver, by the userspace program tcpdump as was seen earlier in the stack trace <br>
```
static void e1000e_set_rx_mode(struct net_device *netdev)
{
	struct e1000_adapter *adapter = netdev_priv(netdev);
	struct e1000_hw *hw = &adapter->hw;
	u32 rctl;

	if (pm_runtime_suspended(netdev->dev.parent))
		return;

	/* Check for Promiscuous and All Multicast modes */
	rctl = er32(RCTL);

	/* clear the affected bits */
	rctl &= ~(E1000_RCTL_UPE | E1000_RCTL_MPE);

	if (netdev->flags & IFF_PROMISC) {
		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);		<-- #define E1000_RCTL_UPE            0x00000008    /* unicast promiscuous enable */
														<-- Code enables promiscuous mode for Unicast and multicast packets
		/* Do not hardware filter VLANs in promisc mode */
		e1000e_vlan_filter_disable(adapter);			<-- Also disables vlan filtering at the MAC
	} else {
		...
		...
	}

	ew32(RCTL, rctl);									<-- Updates the device configuration register
```
To see the RCTL_UPE bitfield value meaning, we refer to the I217 NIC documentation <br>
[RCTL device register](RCTL.png)

bit<3> is set to 1, a.k.a 0x8 implies Unicast Promiscuous enable <br>

## Low level calls

ew32 is a macro function which invokes a normal function after creating a specific register offset <br>

```
#define ew32(reg, val)	__ew32(hw, E1000_##reg, (val))    <--- ## is used to concatenate the string E1000_ and the value in reg (in this case RCTL)
```

The actual low level function that updates the register is 
```
void __ew32(struct e1000_hw *hw, unsigned long reg, u32 val)
{
	if (hw->adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
		__ew32_prepare(hw);

	writel(val, hw->hw_addr + reg);		<--- hw->hw_addr is the base of the memory-mapped address, of the device register memory
}
```

