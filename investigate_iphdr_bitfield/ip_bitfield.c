#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define IPVERSION_SHIFT 4
struct dummy {
	uint8_t version:4;
	uint8_t ihl:4;
	uint8_t tos;
};

struct dummy2 {
	uint8_t version_ihl;
	uint8_t tos;
};

int main()
{
	struct dummy dmy;
	uint8_t *u8ptr;
	int length = sizeof(struct dummy);
	dmy.version = 4;
	dmy.ihl = 5;
	dmy.tos = 1;

	u8ptr = (uint8_t *)&dmy;
	for (int i = 0; i < length; i++) {
		printf("%02x ", u8ptr[i]);
	}
	printf("\n");

	struct dummy2 dmy2;
	dmy2.version_ihl = 5;
	dmy2.version_ihl |= (4 << IPVERSION_SHIFT);
	dmy2.tos = 1;
	u8ptr = (uint8_t *)&dmy2;
	for (int i = 0; i < length; i++) {
		printf("%02x ", u8ptr[i]);
	}
	printf("\n");
	return 0;
}
