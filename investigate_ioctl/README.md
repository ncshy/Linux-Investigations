# Investigating the flow of ioctl calls

'ifconfig' is a user space tool that utilizes ioctl calls to interface with different points in the Kernel to get or set information. <br>

For example, if there is an interface called en2f0np0 with an MTU of 1500B, we can modify this using ifconfig <br>
`
$ sudo ifconfig ens2f0np0 mtu 1280
`

If I trace the system calls (ioctl is one of the system calls), we can see the flow of the ifconfig program. I paste the important parts of the strace output of the above command. <br>

`
socket(AF_INET, SOCK_DGRAM, IPPROTO_IP) = 4	#Opens a network socket

ioctl(4, SIOCSIFMTU, {ifr_name="ens2f0np0", ifr_mtu=1280}) = 0	# Sets interface name and MTU value; SIOCSIFMTU stands for set Interface MTU

`

The code flow in the kernel for the above command is: <br>
`
sys_enter_ioctl			
	dev_ioctl		# A big switch condition where SIOCSIFMTU is one of the matching keys. 
		dev_ifsioc	
			dev_set_mtu
`

I have written a simple program in 'get_tstamp.c'  which invokes an ioctl call that is handled by a network device driver, in this case an mlx5_core driver. Unlike the previous command with IOCTL code SIOCSIFMTU, the IOCTL code SIOCGHWSTAMP used in get_tstamp.c is rerouted to the underlying device driver. <br>

The mlx5_core driver supports an ioctl call that is used to get/set the HW timestamp configuration details. <br>

Executing the binary get_tstamp, we get the below output: <br>
`
$ ./get_tstamp
HW Tstamp config 1) flags, 2) tx_type, 3) rx_filter
1) 0
2) 0
3) 0
`

Printing the kernel stack trace when the binary is executed, we see the following trace: <br>
`
$ sudo bpftrace -e 'k:mlx5e_ioctl {printf("%s", kstack);}'
Attaching 1 probe...

        mlx5e_ioctl+1
        dev_ioctl+896
        sock_do_ioctl+173
        sock_ioctl+243
        __x64_sys_ioctl+149
        do_syscall_64+92
        entry_SYSCALL_64_after_hwframe+98
`

As before, the dev_ioctl has the switch condition and routes the code to the ioctl function implemented by the mlx5_core driver. <br>

The mlx5e_ioctl function calls mlx5e_hwstamp_get which copies the HW_Timestamp configuration to a user provided memory area, which is then accessed by the userspace program and printed out. 



