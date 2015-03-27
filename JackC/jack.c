#include <stdio.h>
#include <string.h>
#include "parser.h"

void usage(char* executable_name);

int main(int argc, char *argv[]) {
  if (argc != 2) {
    usage(argv[0]);
  } else {
    if (strstr(argv[1], ".asm")) {
      parse(argv[1]);
    } else {
      usage(argv[0]);
    }
  }
  return 0;
}

void usage(char* executable_name) {
  printf("usage: %s <input>\n", executable_name);
  printf("A Jack compiler for the Hack platform.\n\n");
  printf("<input.asm>    - Outputs machine code from assembly language\n");
  printf("<input.vm>     - Outputs VM code from assembly language\n");
  printf("<directory>    - Outputs VM code from directory of assembly language files\n");
}
