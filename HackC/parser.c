#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>
#include <string.h>

typedef struct {
  enum {A_COMMAND, C_COMMAND} type;
  char string[16];
  char address[16];
  bool has_dest;
  bool has_jump;
  char comp[5];
  char dest[4];
  char jump[4];
} Command;

typedef struct {
  int command_index;
} Source;

char skip_to_next_command(FILE *file , int c);
char skip_whitespace(FILE *file , int c);
char skip_comments(FILE *file , int c);
bool is_start_of_command(int c);
int read_command(FILE *file , int c, Command commands[], int current_command_index);
void print_commands(Source source, Command commands[]);
void print_command_description(Command command);

void parse(char* filename) {
  FILE *file = fopen(filename, "r");
  if (file == 0) {
    printf("Could not open file\n");
  } else {
    // current char
    int c = fgetc(file);
    // array of assembly commands
    Command commands[1024];
    // Struct to keep track of position etc.
    Source source;
    source.command_index = 0;
    while (!feof(file)) {
      c = skip_to_next_command(file, c);
      c = read_command(file, c, commands, source.command_index);
      if (!feof(file)) {
        source.command_index++;        
      }  
    }

    print_commands(source, commands);

    fclose(file);
  }
}

void print_commands(Source source, Command commands[]) {
  for (int i=0; i<source.command_index; i++) {
    printf("%i\t%s\t", i+1, commands[i].string);
    print_command_description(commands[i]);
    printf("\n");
  }
}

void print_command_description(Command command) {
  printf("// ");
  switch(command.type) {
    case A_COMMAND:
      printf("Loads %s into the A register.", command.address);
      break;
    case C_COMMAND:
      if (command.has_dest) {
        printf("%s=", command.dest);
      }
      printf("%s", command.comp);
      if (command.has_jump) {
        printf(";%s", command.jump);
      }
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
  int address_pos = 0;
  // the at symbol tells us it's a A instruction
  if (c == '@') {
    command.type = A_COMMAND;
  } else {
    command.type = C_COMMAND;    
  }
  while (!feof(file) && !isspace(c)) {
    command.string[pos] = c;
    // everything after the at is a postitive integer (for now, later could be variables)
    if (command.type == A_COMMAND && pos > 0) {
      command.address[address_pos++] = c;
    }
    c = fgetc(file);
    pos++;
  }
  command.string[pos++] = '\0';
  //
  // Now we can work out the C instruction fields
  //
  // C instruction
  // dest=comp;jump
  // either dest or jump may be empty
  // if dest is empty. the '=' is omitted
  // if jump is empty, the ';' is omitted
  //
  // i.e dest=comp;jump, comp;jump, dest=comp.
  command.has_dest = false;
  command.has_jump = false;
  if (strchr(command.string, '=') != NULL) {
    command.has_dest = true;
  }
  if (strchr(command.string, ';') != NULL) {
    command.has_jump = true;
  }
  // dest
  if (command.has_dest) {
    int i = 0;
    char c = command.string[i];
    while(c != '=') {
      command.dest[i++] = c;
      c = command.string[i];
    }
    command.dest[i++] = '\0';
  }

  // comp
  if (!command.has_dest) {
    int i = 0;
    char c = command.string[i];
    while(c != ';' && c != '\0') {
      command.comp[i++] = c;
      c = command.string[i];
    }
    command.comp[i++] = '\0';
  }
  if (!command.has_jump) {
    int i = 0;
    char c = command.string[i];
    while(c != '=') {
      c = command.string[i++];
    }
    int j=0;
    while(c != '\0') {
      c = command.string[i++];
      command.comp[j++] = c;
    }
    command.comp[i++] = '\0';
  }

  // jump
  if (command.has_jump) {
    int i = 0;
    char c = command.string[i];
    while(c != ';') {
      c = command.string[i++];
    }
    int j=0;
    while(c != '\0') {
      c = command.string[i++];
      command.jump[j++] = c;
    }
    command.jump[i++] = '\0';
  }
  commands[current_command_index] = command;
  return c;
}
