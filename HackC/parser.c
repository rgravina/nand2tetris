#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>

int get_next_char(FILE *file, int c);
int skip_to_next_command(FILE *file , int c);
int skip_whitespace(FILE *file , int c);
int skip_comments(FILE *file , int c);

void parse(char* filename) {
  FILE *file = fopen(filename, "r");
  if (file == 0) {
    printf("Could not open file\n");
  } else {
    // int current_file_pointer;
    // bool in_token = false;
    // while ((current_file_pointer = get_next_char(file, current_file_pointer)) != EOF) {
    //   if (current_file_pointer != '\n') {
    //     printf("%c", current_file_pointer);
    //     in_token = false;
    //   } else {
    //     in_token = true;
    //   }
    // }

    // current char
    int c = 0;

    // read first char
    c = fgetc(file);
    printf("%c", c);
    skip_to_next_command(file, c);

    printf("Next char: %i, %c", c, c);
    fclose(file);
  }
}

// int get_next_char(FILE *file , int c) {
//   c = fgetc(file);
//   c = skip_whitespace(file, c, line_number);
//   c = skip_comments(file, c, line_number);
//   return c;
// }


int skip_to_next_command(FILE *file , int c) {
  while (c != EOF) {
    c = skip_whitespace(file, c);
    c = skip_comments(file, c);    
  }
  return c;
}

int skip_whitespace(FILE *file , int c) {
  while (isspace(c)) {
    c = fgetc(file);
    printf("%c", c);
  }
  return c;
}

// will skip anything starting with a forward slash to the end of the line.
// Although comments start with two forward slashes, slashes don't appear
// in assembler instructions so we can avoid looking ahead on character. 
int skip_comments(FILE *file , int c) {
  if (c == '/') {
    while (c != '\n') {
      c = fgetc(file);
      printf("%c", c);
    }
    //consume end of line
    c = fgetc(file);
    printf("%c", c);
  }
  return c;
}
