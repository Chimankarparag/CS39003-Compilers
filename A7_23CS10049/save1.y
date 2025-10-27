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

    struct BaseInfo {
        int b_type;
        int b_width;
        int b_stars;
        int b_tablerow;
    };

    // Helper functions
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
    long ival;           //made here long as it is provided by the lex file which can be both int and long
    char *sval;
    double fval;        //float constant
    struct BaseInfo *bval;
}

%token <sval> ID
%token <ival> NUM
%token <fval> FLTCNST

%token STRUCT LNG INT FLT DBL DOT
%type <bval> M1 M2 M3 M4 C1 C2
%type <ival> BASIC STARS DIMS
%type <ival> N1 N2 N3 N4 
%type <ival> W1 
%start PROG

%%

PROG:  N1 DECLIST   { 
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
            $$->b_stars = 0;
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
            $$->b_stars = 0;
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
            $$ = $<bval>-2; 
            $$->b_stars = $<ival>-1; 
        }
    ;

M4  :   /* Marker inside DIMS to access BaseInfo */
        {
            $$ = $<bval>-3;
        }
    ;

VAR:
    STARS ID M3 DIMS
    {
        int i;
        struct BaseInfo *base_info = $3;
        int base = base_info->b_type;
        int table_no = base_info->b_tablerow;
        int t = base;

        for (i = 0; i < $1; ++i) {
            t = addPointerType(t);
        }

        if ($4 != -1) {
            t = $4;
        }
        addSymbolByName($2, t, table_no);
        free($2);
    }
    ;

STARS:
        /* empty */ 
        { 
            $$ = 0;
        }
    |   STARS '*'   
        { 
            $$ = $1 + 1; 
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
                int ptrcount = b->b_stars;
                int i;
                reftype = b->b_type;
                for (i = 0; i < ptrcount; ++i) {
                    reftype = addPointerType(reftype);
                }
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
    b->b_width = (baseidx >= 0 && baseidx < TT_count) ? TT[baseidx].width : 0;
    b->b_stars = 0;
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

int addPointerType(int reftype) {
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == PTR && TT[i].reference == reftype) {
            return i;
        }
    }
    if (TT_count >= MAX_TYPES) { fprintf(stderr,"Type table overflow\n"); exit(1); }
    TT[TT_count].category = PTR;
    TT[TT_count].reference = reftype;
    TT[TT_count].dimension = 0;
    TT[TT_count].width = 8;  // Pointer size
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