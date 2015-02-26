#include <stdio.h>

void parse(char* filename) {
  FILE *file = fopen(filename, "r");
  if (file == 0) {
    printf("Could not open file\n");
  } else {
    int x;
    while  ((x = fgetc(file)) != EOF) {
      printf("%c", x);
    }
    fclose(file);
  }
}
