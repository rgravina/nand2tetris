#include <stdio.h>
#include <ctype.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>

int MAX_COMMANDS_ALLOWED = 30000;

typedef struct {
  enum {A_COMMAND, C_COMMAND} type;
  char string[14];
  char address[17];
  char instruction[17];
  bool has_dest;
  bool has_jump;
  char dest[4];
  char comp[5];
  char jump[4];
} Command;

struct codeMap {
  char* assembly;
  char* machine_code;
};

const struct codeMap instructionMap[] = {
  {"0",   "101010"},
  {"1",   "111111"},
  {"-1",  "111010"},
  {"D",   "001100"},
  {"A",   "110000"},
  {"M",   "110000"},
  {"!D",  "001101"},
  {"!A",  "110011"},
  {"!M",  "110011"},
  {"-D",  "001111"},
  {"-A",  "110011"},
  {"-M",  "110011"},
  {"D+1", "011111"},
  {"A+1", "110111"},
  {"M+1", "110111"},
  {"D-1", "001110"},
  {"A-1", "110010"},
  {"M-1", "110010"},
  {"D+A", "000010"},
  {"D+M", "000010"},
  {"D-A", "010011"},
  {"D-M", "010011"},
  {"A-D", "000111"},
  {"M-D", "000111"},
  {"D&A", "000000"},
  {"D&M", "000000"},
  {"D|A", "010101"},
  {"D|M", "010101"},
  {NULL, 0}
};

const struct codeMap destMap[] = {
  {"M",   "001"},
  {"D",   "010"},
  {"MD",  "011"},
  {"A",   "100"},
  {"AM",  "101"},
  {"AD",  "110"},
  {"AMD", "111"},
  {NULL, 0}
};

const struct codeMap jumpMap[] = {
  {"JGT", "001"},
  {"JEQ", "010"},
  {"JGE", "011"},
  {"JLT", "100"},
  {"JNE", "101"},
  {"JLE", "110"},
  {"JMP", "111"},
  {NULL, 0}
};

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
void print_command_machine_code(Command command);
unsigned int dec_to_bin(int decimal);
void set_a(Command* command);
void set_command(Command* command);
void set_dest(Command* command);
void set_jump(Command* command);

void parse(char* filename) {
  FILE *file = fopen(filename, "r");
  if (file == 0) {
    printf("Could not open file\n");
  } else {
    // current char
    int c = fgetc(file);
    // array of assembly commands
    Command commands[MAX_COMMANDS_ALLOWED];
    // Struct to keep track of position etc.
    Source source;
    source.command_index = 0;
    while (!feof(file) && source.command_index < MAX_COMMANDS_ALLOWED) {
      c = skip_to_next_command(file, c);
      c = read_command(file, c, commands, source.command_index);
      if (!feof(file)) {
        source.command_index++;        
      }  
    }

    print_commands(source, commands);
    if (source.command_index == MAX_COMMANDS_ALLOWED) {
      printf("----\n");
      printf("Exceeded maximum allowed instructions (%i). Program truncated.\n", MAX_COMMANDS_ALLOWED);
    }

    fclose(file);
  }
}

void print_commands(Source source, Command commands[]) {
  for (int i=0; i<source.command_index; i++) {
   /* printf("%i\t%s\t", i+1, commands[i].string);
    print_command_description(commands[i]);
    printf("\n\t"); */
    print_command_machine_code(commands[i]);
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

void print_command_machine_code(Command command) {
  int dec_address = 0;
  unsigned int bin_address = 0;
  switch(command.type) {
    case A_COMMAND:
      sscanf(command.address, "%d", &dec_address);
      bin_address = dec_to_bin(dec_address);
      sprintf(command.instruction, "%016d", bin_address);
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
  }
  printf("%s", command.instruction);
}

void set_command(Command* command) {
  for (int i = 0; instructionMap[i].assembly != NULL; i++) {
    if (strcmp(command->comp, instructionMap[i].assembly) == 0) {
      command->instruction[4] = instructionMap[i].machine_code[0];
      command->instruction[5] = instructionMap[i].machine_code[1];
      command->instruction[6] = instructionMap[i].machine_code[2];
      command->instruction[7] = instructionMap[i].machine_code[3];
      command->instruction[8] = instructionMap[i].machine_code[4];
      command->instruction[9] = instructionMap[i].machine_code[5];
      return;
    }
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
//  printf("has dest: %i\n", command->has_dest);
  if (command->has_dest) {
    for (int i = 0; destMap[i].assembly != NULL; i++) {
      if (strcmp(command->dest, destMap[i].assembly) == 0) {
        command->instruction[10] = destMap[i].machine_code[0];
        command->instruction[11] = destMap[i].machine_code[1];
        command->instruction[12] = destMap[i].machine_code[2];
        break;
      }
    }
  } else {
    command->instruction[10] = '0';
    command->instruction[11] = '0';
    command->instruction[12] = '0';
  }
}

void set_jump(Command* command) {
//  printf("has jump: %i\n", command->has_jump);
  if (command->has_jump) {
    for (int i = 0; jumpMap[i].assembly != NULL; i++) {
      if (strcmp(command->jump, jumpMap[i].assembly) == 0) {
        command->instruction[13] = jumpMap[i].machine_code[0];
        command->instruction[14] = jumpMap[i].machine_code[1];
        command->instruction[15] = jumpMap[i].machine_code[2];
        break;
      }
    }
  } else {
    command->instruction[13] = '0';
    command->instruction[14] = '0';
    command->instruction[15] = '0';
  }
}

unsigned int dec_to_bin(int decimal) {
  int i = 0;
  unsigned int binary = 0;
  for(i = 0; decimal != 0; i++) {
    binary = binary + pow(10,i) *(decimal%2);
    decimal = decimal/2;
  }
  return binary;
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
  if (command.type == A_COMMAND) {
    command.address[address_pos++] = '\0';
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
