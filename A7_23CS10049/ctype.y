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

    //New categories added for the Statemets

    #define INTCONST 4
    #define FLTCONST 5
    #define TEMP 6
    #define OFFSET 7
    #define TOFFSET 8

    // Type Table Entry
    typedef struct{
        char name[128];
        int category;
        int dimension;
        int reference;
        int width;
    }TypeTable;

    TypeTable TT[MAX_TYPES];
    int TT_count = 0;

    // Symbol Table Entry
    typedef struct{
        char name[128];
        int type;
        int offset;
    }SymbolTableEntry;

    SymbolTableEntry ST_table[MAX_TABLES][MAX_SYMBOLS_PER_TABLE];
    int ST_count[MAX_TABLES];    
    int ST_width[MAX_TABLES];    
    int NumTables = 1;           

    // BaseInfo structure to pass type info
    struct BaseInfo {
        int b_type;
        int b_width;
        int b_tablerow;
    };

    //Address Struct
    //this will help store all the information regarding an object { category for conversion , type for pass and offset for MEM mapping}
    typedef struct{
        int category;
        int data_type; //type of data stored
        int type;      //type in TT
        union{
            long long ival;
            double fval;
            int tempnum;
            int offset;
        }value;
    }Address;

    int temp_counter =1;

    // Helper functions
    void initTypeTable(void);

    int addBasicType(const char *name, int width);
    int addArrayType(int dim, int reftype);
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

    // Three-address code functions
    Address* makeAddress(int cat, int type);
    void freeAddress(Address *a);
    Address* copyAddress(Address *a);

    const char* getTypeName(int typeidx);
    int getBaseType(int typeidx);
    int isNumericType(int typeidx);
    
    Address* loadToTemp(Address *addr);
    Address* typecast(Address *addr, int target_type);
    int widenType(int type1, int type2);

    void emitAssign(Address *lval, Address *rval);
    Address* emitBinaryOp(Address *left, Address *right, char op);
    Address* emitUnaryMinus(Address *operand);

    void printAddress(Address *addr);

%}

%union{
    long ival;           //made here long as it is provided by the lex file which can be both int and long
    char *sval;
    double fval;        //float constant
    struct BaseInfo *bval;
    struct Address *aval;
    int tval;   // for table numbers
}

%token <sval> ID
%token <ival> NUM
%token <fval> FLTCNST

%token STRUCT LNG INT FLT DBL DOT
%type <bval> M1 M2 M3 M4 C1 C2
%type <ival> BASIC DIMS
%type <ival> N1 N2 N3 N4 
%type <ival> W1 
%type <aval> EXPR TERM FACTOR ITEM SMPLITEM AREF
%type <tval> MARKER_ST
%start PROG

%%

PROG:  N1 DECLIST  STMTLIST { 
            printf("+++ All declarations read\n\n"); 
        }
    ;

N1  :   /* Marker to set initial table to 0 (main) */
        {
            $$ = 0;
        }
    ;

DECLIST:
        N2 DECL    
        {

        }
    |    DECLIST N3 DECL  
        {

        }
    ;

N2  :   /* Marker to inherit table number from parent DECLIST */
        {
            $$ = $<ival>0; 
        }
    ;

N3  :   /* Marker to pass table number between DECL items */
        {
            $$ = $<ival>-1; 
        }
    ;

DECL:
        BASIC M1 VARLIST ';' 
        {
            freeBaseInfo($2);
        }
    |   STRUCT ID '{' N4 DECLIST W1 '}'  ';'   
        {
            free($2);
        }
    |   STRUCT ID '{' N4 DECLIST W1 '}' C1 VARLIST ';'   
        {
            freeBaseInfo($8);
            free($2);
        }
    |   STRUCT ID C2 VARLIST ';'   
        { 
            freeBaseInfo($3);
            free($2);
        }
    ;

N4  :   /* Marker to allocate new symbol table for struct */
        {
            $$ = NumTables++; 
            int struct_type = addStructTypeWithTable($<sval>-1, $$);
            ST_count[$$] = 0;
            ST_width[$$] = 0;
        }
    ;

W1  :   /* Marker to capture final width of struct symbol table */
        {
            $$ = ST_width[$<ival>-1]; 
            $$ = align4($$);  
            int struct_type = lookupStructType($<sval>-3);
            if (struct_type != -1)
            TT[struct_type].width = $$; 
        }
    ;

C1  :   /* Marker after struct definition, before VARLIST */
        {
            char *struct_name = $<sval>-5; 
            int struct_type = lookupStructType(struct_name);
            if (struct_type == -1) {
                fprintf(stderr, "Error: Undefined struct '%s'\n", struct_name);
                exit(1);
            }
            $$ = makeBaseInfo(struct_type);
            $$->b_type = struct_type;
            $$->b_tablerow =$<ival>-7 ;
            $$->b_width = TT[struct_type].width;
        }
    ; 

C2  :   /* Marker for using existing struct type */
        {
            char *struct_name = $<sval>0;  
            int struct_type = lookupStructType(struct_name);
            if (struct_type == -1) {
                fprintf(stderr, "Error: Undefined struct '%s'\n", struct_name);
                exit(1);
            }
            $$ = makeBaseInfo(struct_type);
            $$->b_type = struct_type;
            $$->b_tablerow = $<ival>-2;
            $$->b_width = TT[struct_type].width;
        }
    ;

BASIC:
     INT   { $$ = 0; }
    | LNG   { $$ = 1; }
    | FLT   { $$ = 2; }
    | DBL   { $$ = 3; }
    ;

VARLIST:
        VAR
    |   VARLIST ',' M2 VAR
    ;

M1  :   /* Marker after BASIC, to pass type info */
        {
            $$ = makeBaseInfo($<ival>0); 
            $$->b_tablerow = $<ival>-1;
        }
    ;

M2  :   /* Marker to pass base type in VARLIST */
        {
            $$ = $<bval>-2; 
        }
    ;

M3  :   /* Marker after STARS and ID, before DIMS */
        {
            $$ = $<bval>-1; 
        }
    ;

M4  :   /* Marker inside DIMS to access BaseInfo */
        {
            $$ = $<bval>-3;
        }
    ;

VAR:
     ID M3 DIMS
    {
        struct BaseInfo *base_info = $2;
        int base = base_info->b_type;
        int table_no = base_info->b_tablerow;
        int t = base;

        if ($3 != -1) {
            t = $3;
        }
        addSymbolByName($1, t, table_no);
        free($1);
    }
    ;

DIMS:
        /* empty */ 
        {  
            $$ = -1; 
        }
    |   '[' NUM ']' M4 DIMS
        {
            int reftype;
            if ($5 == -1) {
                struct BaseInfo *b = $4;
                reftype = b->b_type;
            } else {
                reftype = $5;
            }
            $$ = addArrayType($2, reftype);
        }
    ;


// Statements 

STMTLIST:
        /* empty */
    |   STMTLIST STMT
    ;

STMT: 
    ASGN
    ;

ASGN: 
        ITEM '=' EXPR ';' 
    ;

EXPR:
        EXPR '+' TERM 
    |   EXPR '-' TERM
    |   TERM
    ;

TERM: 
        TERM '*' FACTOR
    |   TERM '/' FACTOR
    |   TERM '%' FACTOR
    |   FACTOR
    ;

FACTOR:
        NUM
    |   FLTCNST
    |   ITEM
    | '(' EXPR ')'
    ;

ITEM:
        SMPLITEM
    |   ITEM DOT SMPLITEM
    ;

SMPLITEM:
        ID
    |   AREF
    ;

AREF:
        AREF '[' EXPR ']'
    |  ID '[' EXPR ']'
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

struct BaseInfo *makeBaseInfo(int baseidx) {
    struct BaseInfo *b = (struct BaseInfo*)malloc(sizeof(struct BaseInfo));
    if (!b) { perror("malloc"); exit(1); }
    b->b_type = baseidx;
    b->b_width = (baseidx >= 0 && baseidx < TT_count) ? TT[baseidx].width : 0;
    b->b_tablerow = 0;
    return b;
}

void freeBaseInfo(struct BaseInfo *b) {
    if (b) free(b);
}

void initTypeTable(void) {
    TT_count = 0;
    ST_count[0] = 0;
    ST_width[0] = 0;

    addBasicType("int", 4);
    addBasicType("long", 8);

    addBasicType("float", 4);
    addBasicType("double", 8);
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
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == STRUCTURE && strcmp(TT[i].name, struct_name) == 0) {
            return i; 
        }
    }
    
    if (TT_count >= MAX_TYPES) { fprintf(stderr,"Type table overflow\n"); exit(1); }
    TT[TT_count].category = STRUCTURE;
    TT[TT_count].reference = table_row;
    TT[TT_count].dimension = 0;
    TT[TT_count].width = 0; 
    snprintf(TT[TT_count].name, sizeof(TT[TT_count].name), "struct %s", struct_name);
    return TT_count++;
}

int lookupStructType(const char *name) {
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == STRUCTURE) {
            char expected[128];
            snprintf(expected, sizeof(expected), "struct %s", name);
            if (strcmp(TT[i].name, expected) == 0) {
                return i;
            }
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
        fprintf(stderr, "Error: Redeclaration of variable '%s' in table %d\n", name, table_no);
        return;
    }

    if (ST_count[table_no] >= MAX_SYMBOLS_PER_TABLE) {
        fprintf(stderr,"Symbol table overflow\n");
        exit(1);
    }

    int offset = align4(ST_width[table_no]);

    strncpy(ST_table[table_no][ST_count[table_no]].name, name, 127);
    ST_table[table_no][ST_count[table_no]].name[127] = '\0';
    ST_table[table_no][ST_count[table_no]].type = typeidx;
    ST_table[table_no][ST_count[table_no]].offset = offset;
    ST_count[table_no]++;
    ST_width[table_no] = offset + TT[typeidx].width;
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
        snprintf(buf, buflen, "%s [st = %d]", TT[idx].name, TT[idx].reference);
    } else {
        snprintf(buf, buflen, "unknown");
    }
}

void printTypeTable(void) {
    printf("+++ %d types\n", TT_count);
    for (int i = 0; i < TT_count; ++i) {
        char descr[512];
        typeDescr_recursive(i, descr, sizeof(descr));
        printf("    Type %3d: %8d    %s\n", i, TT[i].width, descr);
    }
    printf("\n");
}
void printSymbolTable(void) {
    for (int t = 0; t < NumTables; ++t) {
        if (ST_count[t] == 0) continue;
        
        char table_name[128] = "unknown";
        if (t == 0) {
            strcpy(table_name, "main");
        } else {
            for (int i = 0; i < TT_count; ++i) {
                if (TT[i].category == STRUCTURE && TT[i].reference == t) {
                    strcpy(table_name, TT[i].name);
                    break;
                }
            }
        }

        printf("+++ Symbol table %d [%s]\n", t, table_name);

        for (int i = 0; i < ST_count[t]; ++i) {
            char descr[512];
            typeDescr_recursive(ST_table[t][i].type, descr, sizeof(descr));
            
            int start = ST_table[t][i].offset;
            int width = TT[ST_table[t][i].type].width;
            int end = start + (width > 0 ? width - 1 : 0);

            printf("    %-20s %5d - %-10d  type = %4d = %s\n",
                   ST_table[t][i].name, start, end,
                   ST_table[t][i].type, descr);
        }

        printf("    Total width = %d\n\n", align4(ST_width[t]));
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