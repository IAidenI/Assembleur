#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main () {
	setreuid(geteuid(), geteuid());

	char *name[2];

	name[0] = "/bin/sh";
	name[1] = NULL;
	execve(name[0], name, NULL);
	exit(0);
}

