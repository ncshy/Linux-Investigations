#include <stdio.h>
#include <stdlib.h>
#define MAX_LEN 10

int main() 
{
	char list_str[][MAX_LEN] = {"one", "two", "", "three"};
	
	int list_len = sizeof(list_str)/(MAX_LEN * sizeof(char));
	char *str = &list_str[0][0];

	for (int i = 0; i < list_len * MAX_LEN; i++) {
		if (i % MAX_LEN == 0)
			printf("\n");
		printf("%x ", str[i]);
	}

	return 0;
}
