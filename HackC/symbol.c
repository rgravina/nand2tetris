#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "symbol.h"

const SymbolMap predefinedSymbolMap[] = {
  {"SP", 0},
  {"LCL", 1},
  {"ARG", 2},
  {"THIS", 3},
  {"THAT", 4},
  {"R0", 0},
  {"R1", 1},
  {"R2", 2},
  {"R3", 3},
  {"R4", 4},
  {"R5", 5},
  {"R6", 6},
  {"R7", 7},
  {"R8", 8},
  {"R9", 9},
  {"R10", 10},
  {"R11", 11},
  {"R12", 12},
  {"R13", 13},
  {"R14", 14},
  {"R15", 15},
  {"SCREEN", 16384},
  {"KBD", 24576},
  {NULL, 0}
};

SymbolTable symbol_table;

// Initialises the symbole table
void SymbolTable_init() {
  symbol_table.count = 0;
  // variables begin at RAM address 16
  symbol_table.address = 16;
}

int get_address(char* symbol) {
  for (int i = 0; predefinedSymbolMap[i].assembly != NULL; i++) {
    if (strcmp(symbol, predefinedSymbolMap[i].assembly) == 0) {
      return predefinedSymbolMap[i].address;
    }
  }
  for (int i = 0; i < symbol_table.count; i++) {
    if (strcmp(symbol, symbol_table.table[i]->assembly) == 0) {
      return symbol_table.table[i]->address;
    }
  }
  return -1;
}

void add_symbol(char* symbol, int address) {
  SymbolMap *map = malloc(sizeof(SymbolMap));
  map->assembly = strdup(symbol);
  map->address = address;
  symbol_table.table[symbol_table.count++] = map;
}
