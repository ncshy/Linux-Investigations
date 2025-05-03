#include <stdio.h>

int main()
{
	short int a = -32768;
	short unsigned int b = 32768;

	b >>= 1;
	a >>= 1;

	printf("a is 0x%hx\n", a);
	printf("b is 0x%hx\n", b);
	return 0;
}
