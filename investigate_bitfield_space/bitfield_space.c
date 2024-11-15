#include <stdio.h>
#include <stdlib.h>

struct abitfield {
	unsigned int control:1;
	unsigned int status:1;
	unsigned int wr_complete:1;
	unsigned int dma_complete:1;
	unsigned int offload_enable:2;
	unsigned int :26;
	unsigned int mode_select:2;
};

int main()
{
	struct abitfield abitf = {0};

	abitf.control = 1;
	abitf.status = 1;
	abitf.wr_complete = 1;
	abitf.dma_complete = 1;
	abitf.offload_enable = 3;
	abitf.mode_select = 2;
	int size_abitf = sizeof(abitf);

	printf("size of abitf is %d\n", size_abitf);

	printf("abitf value : %lx\n", abitf);

	return 0;
}
