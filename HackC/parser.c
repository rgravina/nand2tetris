#include <stdio.h>
#include <ctype.h>

int get_next_char(FILE *file, int current_file_pointer);
int skip_whitespace(FILE *file , int current_file_pointer);

void parse(char* filename) {
  FILE *file = fopen(filename, "r");
  if (file == 0) {
    printf("Could not open file\n");
  } else {
    int current_file_pointer;
    while ((current_file_pointer = get_next_char(file, current_file_pointer)) != EOF) {
      printf("%c", current_file_pointer);
    }
    fclose(file);
  }
}

int get_next_char(FILE *file , int current_file_pointer) {
  current_file_pointer = fgetc(file);
  current_file_pointer = skip_whitespace(file, current_file_pointer);
  return current_file_pointer;
}

int skip_whitespace(FILE *file , int current_file_pointer) {
  while (current_file_pointer != '\n' && isspace(current_file_pointer) ) {
    current_file_pointer = fgetc(file);
  }
  return current_file_pointer;
}