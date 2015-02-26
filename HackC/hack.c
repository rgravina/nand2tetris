#include <stdio.h>
#include "parser.h"

void usage(char* executable_name);

int main(int argc, char *argv[]) {
  if (argc != 2) {
    usage(argv[0]);
  } else {
    parse(argv[1]);
  }
  return 0;
}

void usage(char* executable_name) {
  printf("usage: %s <input.asm>\n", executable_name);
  printf("An assembler for the Hack platform.\n");
}
