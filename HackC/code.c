#include <string.h>

// Used to store lookup tables of comp, dest and jump machine code
// from assembly instruction
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
  {"!M",  "110001"},
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

char* comp(char* assembly) {
  for (int i = 0; instructionMap[i].assembly != NULL; i++) {
    if (strcmp(assembly, instructionMap[i].assembly) == 0) {
      return instructionMap[i].machine_code;
    }
  }  
  return NULL;
}

char* dest(char* assembly) {
  for (int i = 0; destMap[i].assembly != NULL; i++) {
    if (strcmp(assembly, destMap[i].assembly) == 0) {
      return destMap[i].machine_code;
    }
  }
  return NULL;
}

char* jump(char* assembly) {
  for (int i = 0; jumpMap[i].assembly != NULL; i++) {
    if (strcmp(assembly, jumpMap[i].assembly) == 0) {
      return jumpMap[i].machine_code;
    }
  }
  return NULL;
}
