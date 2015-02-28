#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>

typedef struct {
  char string[16];
} Command;

char skip_to_next_command(FILE *file , int c);
char skip_whitespace(FILE *file , int c);
char skip_comments(FILE *file , int c);
bool is_start_of_command(int c);
int read_command(FILE *file , int c, Command commands[], int current_command_index);


void parse(char* filename) {
  FILE *file = fopen(filename, "r");
  if (file == 0) {
    printf("Could not open file\n");
  } else {
    // current char
    int c = fgetc(file);
    // array of assembly commands
    Command commands[1024];
    int current_command_index = 0;
    while (!feof(file)) {
      c = skip_to_next_command(file, c);
      c = read_command(file, c, commands, current_command_index);    
      current_command_index++;  
    }

    for (int i=0; i<current_command_index; i++) {
      printf("%s", commands[i].string);
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

int read_command(FILE *file, int c, Command commands[], int current_command_index) {
  if (feof(file)) {
    return c;
  }
  Command command;
  int pos = 0;
  while (!feof(file) && !isspace(c)) {
    command.string[pos++] = c;
    c = fgetc(file);
  }
  command.string[pos++] = '\n';
  commands[current_command_index] = command;
  return c;
}
