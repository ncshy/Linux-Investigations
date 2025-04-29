#include <stdio.h>

int main()
{
	unsigned int a = 2;
	signed int b = -5;

	if ( b > a)
		printf("Type conversion can brick stuff\n");
	else
		printf("Sanity prevails\n");

	return 0;
}
