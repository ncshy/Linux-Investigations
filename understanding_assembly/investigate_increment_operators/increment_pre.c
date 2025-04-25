#include <stdio.h>
#include <stdlib.h>

int main()
{
	int a = 10;
	int result;

	result = ++a + ++a;
	printf("a is %d\n, result is %d\n", a, result);

	return 0;
}
