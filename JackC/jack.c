#include <stdio.h>
#include <string.h>
#include "asm_parser.h"

void usage(char* executable_name);

int main(int argc, char *argv[]) {
  if (argc != 2) {
    usage(argv[0]);
  } else {
    if (strstr(argv[1], ".asm")) {
      parse_assembly(argv[1]);
    } else {
      usage(argv[0]);
    }
  }
  return 0;
}

void usage(char* executable_name) {
  printf("usage: %s <input>\n", executable_name);
  printf("A Jack compiler for the Hack platform.\n\n");
  printf("<input.asm>    - Outputs machine code from assembly code\n");
  printf("<input.vm>     - Outputs assembly code from VM code\n");
  printf("<directory>    - Outputs assembly code from directory of VM code files\n");
}
