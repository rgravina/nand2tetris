int get_address(char* symbol);
void add_symbol(char* symbol, int address);
void SymbolTable_init();

#define MAX_SYMBOLS 10000

typedef struct {
  char* assembly;
  int address;
} SymbolMap;

typedef struct {
  SymbolMap *table[MAX_SYMBOLS];
  int count;
  int address;
} SymbolTable;

SymbolTable symbol_table;
