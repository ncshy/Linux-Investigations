#include <stdio.h>

int main()
{
	int a = 20;
	int b = 10;
	int c = 5;
	int d = 2;

	if (a < b && a < c && a < d) {
		printf("%d is smallest element\n", a);
	} else {
		printf("%d is not the smallest element\n", a);
	}
	return 0;
}
