#include<stdio.h>
#include<errno.h>
#include<stdlib.h>
#include <asm/types.h>
#include <sys/socket.h>
#include <linux/netlink.h>

void receive_update() 
{

}

int main()
{

        int fd;
        struct sockaddr_nl sanl;
        memset(sanl, 0, sizeof(sanl));
        sanl.nl_family = AF_NETLINK;
        /* Request data from kernel */
        sanl.nl_pid = 0;
        /* Register with kernel group */
        sanl.nl_groups = RTMGRP_IPV4_IFADDR;

        /* Open and bind the netlink socket */
        fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_CRYPTO);
        if(fd < 0) {
                perror("Could not create socket\n");
                return -1;
        }
        ret = bind(fd, (struct sockaddr *)&sanl, sizeof(sockaddr_nl));
        if(ret < 0) {
                perror("Socket bind failed\n");
                return -1;
        }

        while 1 {
                receive_update();
        }
}
