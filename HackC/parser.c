#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>

char skip_to_next_command(FILE *file , int c);
char skip_whitespace(FILE *file , int c);
char skip_comments(FILE *file , int c);
bool is_start_of_command(int c);
int read_command(FILE *file , int c);

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
    int c;
    // read first char
    c = fgetc(file);
    //printf("%c", c);

    while (!feof(file)) {
      c = skip_to_next_command(file, c);
      c = read_command(file, c);      
    }
    
    fclose(file);
  }
}

// Skips all whitespace and comments until the
// start of the next command
char skip_to_next_command(FILE *file, int c) {
  while (!(feof(file) || is_start_of_command(c))) {
    c = skip_whitespace(file, c);
    c = skip_comments(file, c);
  }
  return c;
}

// Skips whitespace (including newlines)
char skip_whitespace(FILE *file, int c) {
  while (!feof(file) && isspace(c)) {
    c = fgetc(file);
    //printf("%c", c);
  }
  return c;
}

// will skip anything starting with a forward slash to the end of the line.
// Although comments start with two forward slashes, slashes don't appear
// in assembler instructions so we can avoid looking ahead on character. 
char skip_comments(FILE *file, int c) {
  if (c == '/') {
    while (!feof(file) && c != '\n') {
      c = fgetc(file);
      //printf("%c", c);
    }
    //consume end of line
    if (c == '\n') { 
      c = fgetc(file);      
    }
    //printf("%c", c);
  }
  return c;
}

// Returns true if start of a command.
// Uses a really simple switch on all possible chars
// in the assembly language (or a digit).
bool is_start_of_command(int c) {
  switch(c) {
    case '@':
    case 'D':
    case 'M':
    case 'A':
    case '=':
    case '+':
    case '-':
    case ';':
    case 'J':
    case 'G':
    case 'T':
    case 'L':
    case 'E':
      return true;
      break;
    default:
      return isdigit(c);
  }
}

int read_command(FILE *file, int c) {
  if (feof(file)) {
    return c;
  }
  printf("<command>");
  while (!feof(file) && !isspace(c)) {
    printf("%c", c);
    c = fgetc(file);
  }
  printf("</command>\n");
  return c;
}
