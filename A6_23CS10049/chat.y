%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>

    int yylex(void);
    extern FILE* yyin;
    void yyerror(const char *s);

    #define MAX_TYPES 1000
    #define MAX_TABLES 100
    #define MAX_SYMBOLS_PER_TABLE 1000

    #define BASE 0
    #define ARR 1
    #define PTR 2
    #define STRUCTURE 3

    typedef struct{
        char name[128];
        int category;
        int dimension;
        int reference;
        int width;
    }TypeTable;

    TypeTable TT[MAX_TYPES];
    int TT_count = 0;

    typedef struct{
        char name[128];
        int type;
        int offset;
    }SymbolTableEntry;

    SymbolTableEntry ST_table[MAX_TABLES][MAX_SYMBOLS_PER_TABLE];
    int ST_count[MAX_TABLES];    
    int ST_width[MAX_TABLES];    
    int NumTables = 1;           

    struct BaseInfo {
        int b_type;
        int b_width;
        int b_stars;
        int b_tablerow;
    };

    void initTypeTable(void);
    int addBasicType(const char *name, int width);
    int addArrayType(int dim, int reftype);
    int addPointerType(int reftype);
    int addStructTypeWithTable(const char* struct_name, int table_row);
    void printTypeTable(void);
    void printSymbolTable(void);
    int lookupSymbol(const char *name, int table_no);
    int lookupStructType(const char *name);
    void addSymbolByName(const char *name, int typeidx, int table_no);
    int align4(int x);
    struct BaseInfo *makeBaseInfo(int baseidx);
    void freeBaseInfo(struct BaseInfo *b);
    void typeDescr_recursive(int idx, char *buf, int buflen);

%}

%union{
    int ival;
    char *sval;
    struct BaseInfo *bval;
}

%token <sval> ID
%token <ival> NUM

%token STRUCT VOID UCHR CHR SRT USRT LNG ULNG UINT INT FLT DBL
%type <bval> M1 M2 M3 M4 C1 C2
%type <ival> BASIC STARS DIMS
%type <ival> N1 N2 N3 N4 W1

%start PROG

%%

PROG: N1 DECLIST { printf("+++ All Declarations read\n\n"); }
    ;

DECLIST:
        N2 DECL
    |   N2 DECLIST N3 DECL
    ;

DECL:
        BASIC M1 VARLIST ';' {
            freeBaseInfo($2);
        }
    |   STRUCT ID '{' N4 DECLIST W1 '}' ';' {
            int struct_type = addStructTypeWithTable($2, $4);
            TT[struct_type].width = $6;
            free($2);
        }
    |   STRUCT ID '{' N4 DECLIST W1 '}' C1 VARLIST ';' {
            freeBaseInfo($8);
        }
    |   STRUCT ID C2 VARLIST ';' {
            freeBaseInfo($3);
            free($2);
        }
    ;

N1: {
        $$ = 0;  // Main symbol table
    }
    ;

N2: {
        $$ = $<ival>0;  // Inherit table row from parent
    }
    ;

N3: {
        $$ = $<ival>-1;  // Pass table row from previous DECLIST
    }
    ;

N4: {
        $$ = NumTables++;  // Allocate new table for struct
        ST_count[$$] = 0;
        ST_width[$$] = 0;
    }
    ;

W1: {
        $$ = ST_width[$<ival>-3];  // Return width of the struct table (N4 is 3 positions back)
    }
    ;

C1: {
        // Create struct type and make BaseInfo with that type
        char *struct_name = $<sval>-5;  // ID is 5 positions back
        int table_no = $<ival>-4;        // N4 is 4 positions back
        int width = $<ival>-1;           // W1 is 1 position back
        int parent_table = $<ival>-7;    // N2 is 7 positions back
        
        int struct_type = addStructTypeWithTable(struct_name, table_no);
        TT[struct_type].width = width;
        
        $$ = makeBaseInfo(struct_type);
        $$->b_tablerow = parent_table;  // Variables go in parent table
    }
    ;

C2: {
        // Lookup existing struct type and make BaseInfo
        char *struct_name = $<sval>-1;  // ID is 1 position back
        int parent_table = $<ival>-2;    // N2 is 2 positions back
        
        int struct_type = lookupStructType(struct_name);
        if (struct_type == -1) {
            fprintf(stderr, "Error: Undefined structure '%s'\n", struct_name);
            // Create a dummy BaseInfo to avoid crashes
            $$ = makeBaseInfo(0);
        } else {
            $$ = makeBaseInfo(struct_type);
            $$->b_tablerow = parent_table;  // Variables go in parent table
        }
    }
    ;

BASIC:
      VOID  { $$ = 0; }
    | UCHR  { $$ = 1; }
    | CHR   { $$ = 2; }
    | USRT  { $$ = 3; }
    | SRT   { $$ = 4; }
    | ULNG  { $$ = 5; }
    | LNG   { $$ = 6; }
    | UINT  { $$ = 7; }
    | INT   { $$ = 8; }
    | FLT   { $$ = 9; }
    | DBL   { $$ = 10; }
    ;

VARLIST:
        VAR
    |   VARLIST ',' M2 VAR
    ;

M1: {
        $$ = makeBaseInfo($<ival>0);
        $$->b_tablerow = $<ival>-1;
    }
    ;

M2: {
        $$ = $<bval>-2;
    }
    ;

M3: {
        $$ = $<bval>-2; 
        $$->b_stars = $<ival>-1; 
    }
    ;

M4: {
        $$ = $<bval>-3; 
    }
    ;

VAR: STARS ID M3 DIMS {
        int i;
        struct BaseInfo *b = $<bval>3;
        int base = b->b_type;
        int t = base;
        int table_no = b->b_tablerow;

        for (i = 0; i < $1; ++i) t = addPointerType(t);

        if ($4 == -1) {
            addSymbolByName($2, t, table_no);
        } else {
            addSymbolByName($2, $4, table_no);
        }
        free($2);
    }
    ;

STARS:
        { $$ = 0; }
    | STARS '*' { $$ = $1 + 1; }
    ;

DIMS:
        { $$ = -1; }
    | '[' NUM ']' M4 DIMS {
        int reftype;
        if ($5 == -1) {
            struct BaseInfo *b = $<bval>4;
            int ptrcount = b->b_stars;
            int i;
            reftype = b->b_type;
            for (i = 0; i < ptrcount; ++i) reftype = addPointerType(reftype);
        } else {
            reftype = $5;
        }
        $$ = addArrayType($2, reftype);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

struct BaseInfo *makeBaseInfo(int baseidx) {
    struct BaseInfo *b = (struct BaseInfo*)malloc(sizeof(struct BaseInfo));
    if (!b) { perror("malloc"); exit(1); }
    b->b_type = baseidx;
    b->b_width = TT[baseidx].width;
    b->b_stars = 0;
    b->b_tablerow = 0;
    return b;
}

void freeBaseInfo(struct BaseInfo *b) {
    if (b) free(b);
}

void initTypeTable(void) {
    TT_count = 0;
    addBasicType("void", 0);
    addBasicType("unsigned char", 1);
    addBasicType("char", 1);
    addBasicType("unsigned short", 2);
    addBasicType("short", 2);
    addBasicType("unsigned long", 8);
    addBasicType("long", 8);
    addBasicType("unsigned int", 4);
    addBasicType("int", 4);
    addBasicType("float", 4);
    addBasicType("double", 8);
    
    for (int i = 0; i < MAX_TABLES; i++) {
        ST_count[i] = 0;
        ST_width[i] = 0;
    }
}

int addBasicType(const char *name, int width) {
    if (TT_count >= MAX_TYPES) { fprintf(stderr,"Type table overflow\n"); exit(1); }
    TT[TT_count].category = BASE;
    TT[TT_count].dimension = 0;
    TT[TT_count].reference = -1;
    TT[TT_count].width = width;
    strncpy(TT[TT_count].name, name, sizeof(TT[TT_count].name)-1);
    TT[TT_count].name[sizeof(TT[TT_count].name)-1] = '\0';
    return TT_count++;
}

int addPointerType(int reftype) {
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == PTR && TT[i].reference == reftype) return i;
    }
    if (TT_count >= MAX_TYPES) { fprintf(stderr,"Type table overflow\n"); exit(1); }
    TT[TT_count].category = PTR;
    TT[TT_count].reference = reftype;
    TT[TT_count].dimension = 0;
    TT[TT_count].width = 8;
    char inner[256];
    typeDescr_recursive(reftype, inner, sizeof(inner));
    snprintf(TT[TT_count].name, sizeof(TT[TT_count].name), "pointer(%s)", inner);
    return TT_count++;
}

int addArrayType(int dim, int reftype) {
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == ARR && TT[i].dimension == dim && TT[i].reference == reftype) {
            return i;
        }
    }
    if (TT_count >= MAX_TYPES) { fprintf(stderr,"Type table overflow\n"); exit(1); }
    TT[TT_count].category = ARR;
    TT[TT_count].dimension = dim;
    TT[TT_count].reference = reftype;
    long long w = (long long)dim * (long long)TT[reftype].width;
    TT[TT_count].width = (int)w;
    char inner[256];
    typeDescr_recursive(reftype, inner, sizeof(inner));
    snprintf(TT[TT_count].name, sizeof(TT[TT_count].name), "array(%d,%s)", dim, inner);
    return TT_count++;
}

int addStructTypeWithTable(const char* struct_name, int table_row) {
    // Check if struct already exists
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == STRUCTURE && strcmp(TT[i].name, struct_name) == 0) {
            return i;
        }
    }
    if (TT_count >= MAX_TYPES) { fprintf(stderr,"Type table overflow\n"); exit(1); }
    TT[TT_count].category = STRUCTURE;
    TT[TT_count].dimension = table_row;
    TT[TT_count].reference = -1;
    TT[TT_count].width = 0;
    snprintf(TT[TT_count].name, sizeof(TT[TT_count].name), "struct %s", struct_name);
    return TT_count++;
}

int lookupStructType(const char *name) {
    char full_name[256];
    snprintf(full_name, sizeof(full_name), "struct %s", name);
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == STRUCTURE && strcmp(TT[i].name, full_name) == 0) {
            return i;
        }
    }
    return -1;
}

int lookupSymbol(const char *name, int table_no) {
    for (int i = 0; i < ST_count[table_no]; ++i) {
        if (strcmp(ST_table[table_no][i].name, name) == 0) {
            return i; 
        }
    }
    return -1;
}

void addSymbolByName(const char *name, int typeidx, int table_no) {
    if (lookupSymbol(name, table_no) != -1) {
        fprintf(stderr, "Error: Redeclaration of variable '%s'\n", name);
        return; 
    }
    if (ST_count[table_no] >= MAX_SYMBOLS_PER_TABLE) { 
        fprintf(stderr,"Symbol table overflow\n"); exit(1); 
    }
    strncpy(ST_table[table_no][ST_count[table_no]].name, name, 127);
    ST_table[table_no][ST_count[table_no]].name[127] = '\0';
    ST_table[table_no][ST_count[table_no]].type = typeidx;
    ST_table[table_no][ST_count[table_no]].offset = TT[typeidx].width;
    ST_count[table_no]++;
    ST_width[table_no] += align4(TT[typeidx].width);
}

int align4(int x) {
    if (x % 4 == 0) return x;
    return x + (4 - (x % 4));
}

void typeDescr_recursive(int idx, char *buf, int buflen) {
    if (idx < 0 || idx >= TT_count) { snprintf(buf, buflen, "??"); return; }
    if (TT[idx].category == BASE) {
        snprintf(buf, buflen, "%s", TT[idx].name);
    } else if (TT[idx].category == PTR) {
        char inner[256];
        typeDescr_recursive(TT[idx].reference, inner, sizeof(inner));
        snprintf(buf, buflen, "pointer(%s)", inner);
    } else if (TT[idx].category == ARR) {
        char inner[256];
        typeDescr_recursive(TT[idx].reference, inner, sizeof(inner));
        snprintf(buf, buflen, "array(%d,%s)", TT[idx].dimension, inner);
    } else if (TT[idx].category == STRUCTURE) {
        snprintf(buf, buflen, "%s with symbol table %d", TT[idx].name, TT[idx].dimension);
    } else {
        snprintf(buf, buflen, "unknown");
    }
}

void printTypeTable(void) {
    printf("+++ %d types\n", TT_count);
    for (int i = 0; i < TT_count; ++i) {
        printf("    Type %3d: %8d    %s", i, TT[i].width, TT[i].name);
        if (TT[i].category == STRUCTURE) {
            printf(" with symbol table %d", TT[i].dimension);
        }
        printf("\n");
    }
    printf("\n");
}

void printSymbolTable(void) {
    for (int tbl = 0; tbl < NumTables; tbl++) {
        if (tbl == 0) {
            printf("+++ Symbol table 0 [main]\n");
        } else {
            // Find the struct name for this table
            for (int i = 0; i < TT_count; i++) {
                if (TT[i].category == STRUCTURE && TT[i].dimension == tbl) {
                    printf("+++ Symbol table %d [%s]\n", tbl, TT[i].name);
                    break;
                }
            }
        }
        
        int st_offset = 0;
        for (int i = 0; i < ST_count[tbl]; ++i) {
            char descr[512];
            int end_offset = st_offset + ST_table[tbl][i].offset - 1;
            typeDescr_recursive(ST_table[tbl][i].type, descr, sizeof(descr));
            printf("    %-18s %4d - %4d         type = %4d = %s\n",
                   ST_table[tbl][i].name, st_offset, end_offset, 
                   ST_table[tbl][i].type, descr);
            st_offset += align4(ST_table[tbl][i].offset);
        }
        printf("    Total width = %d\n", st_offset);
    }
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { perror("fopen"); return 1; }
        yyin = f;
    }
    initTypeTable();
    if (yyparse() == 0) {
        printTypeTable();
        printSymbolTable();
    } else {
        fprintf(stderr, "Parsing failed\n");
    }
    return 0;
}