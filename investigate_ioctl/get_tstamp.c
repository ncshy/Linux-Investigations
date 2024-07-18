#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <linux/if.h>
#include <linux/sockios.h>
#include <string.h>

struct hwtstamp_config {
	int flags;
	int tx_type;
	int rx_filter;
};

int main()
{
	int sockfd;
	int ret = 0;
	struct hwtstamp_config  *tconfig;
	struct ifreq req;
	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	if (sockfd < 0) {
		printf("socket creation failed\n");
		return -1;
	}
	char ifname[] = "ens2f0np0";
	memcpy(&req.ifr_name, ifname, sizeof(ifname));

	ret = ioctl(sockfd, SIOCGHWTSTAMP, &req);
	if (ret < 0) {
		printf("ioctl call failed\n");
		return -1;
	}

	tconfig = (struct hwtstamp_config *)req.ifr_data;

	printf("HW Tstamp config 1) flags, 2) tx_type, 3) rx_filter\n");
	printf("1) %d\n", tconfig->flags);
	printf("2) %d\n", tconfig->tx_type);
	printf("3) %d\n", tconfig->rx_filter);

	return 0;
}
