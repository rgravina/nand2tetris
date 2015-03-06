int get_address(char* symbol);
void add_symbol(char* symbol, int address);

#define MAX_SYMBOLS 10000

typedef struct {
  char* assembly;
  int address;
} SymbolMap;

typedef struct {
  SymbolMap *table[MAX_SYMBOLS];
  int count;
} SymbolTable;

SymbolTable symbol_table;
