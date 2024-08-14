#include <stdio.h>
#include <stdlib.h>

extern int sum(int a, int b);
#define sum(a,b) (sum((a), (b)))

int main()
{
	int a = 3, b = 5;

	int c = sum(3, 5);
	printf("Sum is %d\n", c);
	return 0;
}
