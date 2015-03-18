#include <stdio.h>
#include <stdlib.h>

int main() {
	int i;
	char c;
	FILE *saved_stdout = stdout;
	freopen("my_stdout", "w", stdout);

	// read to stdin to new stdout
	scanf("%d", &i);

	printf("number %d", i);
	freopen("my_stdout", "r", stdin);
	freopen("file.txt", "w", stdout);

	while(scanf("%c", &c) != EOF) {
		printf("%c written\n", c);
	}

	return 0;
}