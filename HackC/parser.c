#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include "code.h"
#include "symbol.h"

// TODO: use a linked list of commands
int MAX_COMMANDS_ALLOWED = 30000;

// All information about a command
// Added a type for symbol definitions, although not really a command
typedef struct {
  enum {A_COMMAND, C_COMMAND, S_COMMAND} type;
  char address[34];
  char instruction[34];
  bool has_dest;
  bool has_jump;
  char dest[4];
  char comp[5];
  char jump[4];
} Command;

// stores info about the current source file
typedef struct {
  int line;
  int command_index;
  FILE *file;
} Source;

bool is_start_of_command(char c);
bool is_start_of_symbol(char c);
void dec_to_bin(int decimal, char* binary);
char skip_to_next_command(Source* source);
char skip_whitespace(Source* source);
char skip_comments(Source* source);
char read_command(Source* source, Command commands[]);
void print_commands(Source source, Command commands[]);
void print_command_description(Command command);
void print_command_machine_code(Command command);
void set_address(Command* command);
void set_a(Command* command);
void set_command(Command* command);
void set_dest(Command* command);
void set_jump(Command* command);

void parse(char* filename) {
  Source source;
  source.file = fopen(filename, "r");
  source.line = 1;
  if (source.file == 0) {
    printf("Could not open file\n");
  } else {
    // array of assembly commands
    Command commands[MAX_COMMANDS_ALLOWED];
    // Struct to keep track of position etc.
    source.command_index = 0;
    while (!feof(source.file) && source.command_index < MAX_COMMANDS_ALLOWED) {
      skip_to_next_command(&source);
      read_command(&source, commands);
      if (!feof(source.file)) {
        source.command_index++;        
      }  
    }

    print_commands(source, commands);
    if (source.command_index == MAX_COMMANDS_ALLOWED) {
      printf("----\n");
      printf("Exceeded maximum allowed instructions (%i). Program truncated.\n", MAX_COMMANDS_ALLOWED);
    }

    fclose(source.file);
  }
}

void print_commands(Source source, Command commands[]) {
  for (int i=0; i<source.command_index; i++) {
    //printf("%i\t%s\t", i+1, commands[i].string);
    //print_command_description(commands[i]);
    //printf("\n\t");
    print_command_machine_code(commands[i]);
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
      break;
    case S_COMMAND:
      break;
  }
}

void print_command_machine_code(Command command) {
  int dec_address = 0;
  // initialise all bits to zero
  for (int i=0; i<16; i++) {
    command.instruction[i] = '0';
  }
  command.instruction[16] = '\0';
  switch(command.type) {
    case A_COMMAND:
      if (isdigit(command.address[0])) {
        sscanf(command.address, "%d", &dec_address);
        dec_to_bin(dec_address, command.instruction);
      } else {
        set_address(&command);
      }
      printf("%s\n", command.instruction);
      break;
    case C_COMMAND:
      command.instruction[0] = '1';
      // unused bits
      command.instruction[1] = '1';
      command.instruction[2] = '1';
      set_command(&command);
      set_a(&command);
      set_dest(&command);
      set_jump(&command);
      command.instruction[16] = '\0';
      printf("%s\n", command.instruction);
      break;
    case S_COMMAND:
      printf("%s\n", command.address);
      break;
  }
}

void set_address(Command* command) {
  for (int i = 0; predefinedSymbolMap[i].assembly != NULL; i++) {
    if (strcmp(command->address, predefinedSymbolMap[i].assembly) == 0) {
      dec_to_bin(predefinedSymbolMap[i].address, command->instruction);
      return;
    }
  }
}

void set_command(Command* command) {
  char* code = comp(command->comp);
  if (code != NULL) {
    command->instruction[4] = code[0];
    command->instruction[5] = code[1];
    command->instruction[6] = code[2];
    command->instruction[7] = code[3];
    command->instruction[8] = code[4];
    command->instruction[9] = code[5];
  }
}

void set_a(Command* command) {
  // If the comp section uses M, then the a-bit shoul be on
  if (strchr(command->comp, 'M') != NULL) {
    command->instruction[3] = '1';
  } else {
    command->instruction[3] = '0';
  }
}

void set_dest(Command* command) {
  if (command->has_dest) {
    char* code = dest(command->dest);
    if (code != NULL) {
      command->instruction[10] = code[0];
      command->instruction[11] = code[1];
      command->instruction[12] = code[2];
    }
  }
}

void set_jump(Command* command) {
  if (command->has_jump) {
    char* code = jump(command->jump);
    if (code != NULL) {
      command->instruction[13] = code[0];
      command->instruction[14] = code[1];
      command->instruction[15] = code[2];
    }
  }
}

void dec_to_bin(int decimal, char* binary) {
  if (decimal == 0) {
    return;
  }
  int rem = 0;
  for(int i = 15; decimal != 0; i--) {
    rem = decimal % 2;
    decimal /= 2;
    binary[i] = rem+'0';
  }
}

// Skips all whitespace and comments until the
// start of the next command
char skip_to_next_command(Source* source) {
  char c = fgetc(source->file);
  while (!(feof(source->file) || is_start_of_command(c) || is_start_of_symbol(c))) {
    c = skip_whitespace(source);
    c = skip_comments(source);
    if (!(is_start_of_command(c) || is_start_of_symbol(c) || isspace(c) || c == '/' || c == '\n' || c == -1)) {
      printf("Parse error on line %i. Unexpected char: '%c'.\n", source->line, c);
      exit(0);
    }
  }
  return c;
}

// Skips whitespace (including newlines)
char skip_whitespace(Source* source) {
  char c = fgetc(source->file);
  while (!feof(source->file) && isspace(c)) {
    c = fgetc(source->file);
    if (c == '\n') {
      source->line++;
    }
  }
  ungetc(c, source->file);
  return c;
}

// will skip anything starting with a forward slash to the end of the line.
// Although comments start with two forward slashes, slashes don't appear
// in assembler instructions so we can avoid looking ahead on character. 
char skip_comments(Source* source) {
  char c = fgetc(source->file);
  if (c == '/') {
    while (!feof(source->file) && c != '\n') {
      c = fgetc(source->file);
    }
    if (c == '\n') { 
      source->line++;
    }
  } else {
    ungetc(c, source->file);
  }
  return c;
}

// Returns true if start of a command.
// Uses a really simple switch on all possible chars
// in the assembly language (or a digit).
bool is_start_of_command(char c) {
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
    case '(':
      return true;
      break;
    default:
      return isdigit(c);
  }
}

bool is_start_of_symbol(char c) {
  if (c == '(') {
    return true;
  } else {
    return false;
  }
}

char read_command(Source* source, Command commands[]) {
  char c = fgetc(source->file);
  char string[34];
  if (feof(source->file)) {
    return c;
  }
  Command command;
  int pos = 0;
  int address_pos = 0;
  int symbol_pos = 0;
  // the at symbol tells us it's a A instruction
  if (c == '@') {
    command.type = A_COMMAND;
  } else if (c == '(') {
    command.type = S_COMMAND;
    while (!feof(source->file) && !isspace(c)) {
      if (c != '(' && c != ')') {
        command.address[symbol_pos++] = c;
      }
      c = fgetc(source->file);
      pos++;
    }
    command.address[symbol_pos++] = '\0';
  } else {
    command.type = C_COMMAND;    
  }
  while (!feof(source->file) && !isspace(c)) {
    string[pos] = c;
    // everything after the at is a postitive integer or a symbol name
    if (command.type == A_COMMAND && pos > 0) {
      command.address[address_pos++] = c;
    }
    c = fgetc(source->file);
    pos++;
  }
  if (command.type == A_COMMAND) {
    command.address[address_pos++] = '\0';
  } else if (command.type == C_COMMAND) {
    string[pos++] = '\0';
  }
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
  if (strchr(string, '=') != NULL) {
    command.has_dest = true;
  }
  if (strchr(string, ';') != NULL) {
    command.has_jump = true;
  }
  // dest
  if (command.has_dest) {
    int i = 0;
    char c = string[i];
    while(c != '=') {
      command.dest[i++] = c;
      c = string[i];
    }
    command.dest[i++] = '\0';
  }

  // comp
  if (!command.has_dest) {
    int i = 0;
    char c = string[i];
    while(c != ';' && c != '\0') {
      command.comp[i++] = c;
      c = string[i];
    }
    command.comp[i++] = '\0';
  }
  if (!command.has_jump) {
    int i = 0;
    char c = string[i];
    while(c != '=') {
      c = string[i++];
    }
    int j=0;
    while(c != '\0') {
      c = string[i++];
      command.comp[j++] = c;
    }
    command.comp[i++] = '\0';
  }

  // jump
  if (command.has_jump) {
    int i = 0;
    char c = string[i];
    while(c != ';') {
      c = string[i++];
    }
    int j=0;
    while(c != '\0') {
      c = string[i++];
      command.jump[j++] = c;
    }
    command.jump[i++] = '\0';
  }
  commands[source->command_index] = command;
  return c;
}
