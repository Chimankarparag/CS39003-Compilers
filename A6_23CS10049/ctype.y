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

    // structs

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

    int table_stack[MAX_TABLES];
    int table_stack_top = -1;

    struct BaseInfo {
    int b_type;
    int b_width;
    int b_stars;
    int b_tablerow;
    };

    //helperfunction

    void initTypeTable(void);

    int addBasicType(const char *name, int width);
    int addArrayType(int dim, int reftype);
    int addPointerType(int reftype);
    int addStructTypeWithTable( const char* struct_name , int table_row);

    void printTypeTable(void);
    void printSymbolTable(void);

    int lookupSymbol(const char *name);
    void addSymbolByName(const char *name, int typeidx);
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
%type <bval> M1 M2 M3 M4
%type <ival> BASIC STARS DIMS
%type <ival> N1 N2

%start PROG

%%

PROG:  N1 DECLIST   { printf("+++ All Declarations read\n\n"); }
    ;

DECLIST:
        N2 DECL    {

        }
    |   N2 DECLIST N3 DECL  {

        }
    ;
DECL:
        BASIC M1 VARLIST ';' {
            freeBaseInfo($2);
        }
    |   STRUCT ID '{' N4 DECLIST  '}'  ';'   {


        }
    |   STRUCT ID '{' N4 DECLIST  '}' VARLIST ';'   {


        }
    |   STRUCT ID VARLIST ';'   { 

        }
    ;

N1  :
    {
        $$ = 0;
    }
    ;

N2  :
    {
        $$ = $<ival>0;
    }
    ;

N3  :
    {
        $$ = $<ival>-1;
    }
    ;

N4  :
    {
        //update the struct table no.
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

//M1 inherits and basic
M1:
    {
        $$ = makeBaseInfo($<ival>0);
        $$->b_tablerow = $<ival>-1;
    }
    ;
// M2 reads M1 to get Basic
M2:
    {
        $$ = $<bval>-2;
    }
    ;

M3:
    {
        $$ = $<bval>-2; 
        $$->b_stars = $<ival>-1; 
    }
    ;

M4:
    {
        $$ = $<bval>-3; 
    }
    ;

VAR:
    STARS ID M3 DIMS
    {
        int i;
        int base = $<bval>0->b_type;
        int t = base;

        for (i = 0; i < $1; ++i) t = addPointerType(t);

        if ($4 == -1) {
            addSymbolByName($2, t);
        } else {
            addSymbolByName($2, $4);
        }
        free($2);
    }
    ;

STARS:
        /* empty */ { 
             $$ = 0;
    }
    | STARS '*'   { 
        $$ = $1 + 1; 
    
    }
    ;


DIMS:
        /* empty */ {  $$ = -1; }
    | '[' NUM ']' M4 DIMS
    {
        int reftype;
        if ($5 == -1) {
            struct BaseInfo *b = $<bval>0;
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
    return b;
}
void freeBaseInfo(struct BaseInfo *b) {
    if (b) free(b);
}

void initTypeTable(void) {
    TT_count = 0;
    addBasicType("void", 0);
    addBasicType("unsigned char", (int)sizeof(unsigned char));
    addBasicType("char", (int)sizeof(char));
    addBasicType("unsigned short", (int)sizeof(unsigned short));
    addBasicType("short", (int)sizeof(short));
    addBasicType("unsigned long", (int)sizeof(unsigned long));
    addBasicType("long", (int)sizeof(long));
    addBasicType("unsigned int", (int)sizeof(unsigned int));
    addBasicType("int", (int)sizeof(int));
    addBasicType("float", (int)sizeof(float));
    addBasicType("double", (int)sizeof(double));
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
    /* Check if such a pointer type already exists; if so return it. */
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == PTR && TT[i].reference == reftype) return i;
    }
    if (TT_count >= MAX_TYPES) { fprintf(stderr,"Type table overflow\n"); exit(1); }
    TT[TT_count].category = PTR;
    TT[TT_count].reference = reftype;
    TT[TT_count].dimension = 0;
    TT[TT_count].width = (int)sizeof(void *);
    char inner[256];
    typeDescr_recursive(reftype, inner, sizeof(inner));
    snprintf(TT[TT_count].name, sizeof(TT[TT_count].name), "pointer(%s)", inner);
    return TT_count++;
}

int addArrayType(int dim, int reftype) {
    /* Check if such an array type already exists; if so return it. */
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

int lookupSymbol(const char *name) {
    for (int i = 0; i < ST_count; ++i) {
        if (strcmp(ST[i].name, name) == 0) {
            return i; 
        }
    }
    return -1;
}
void addSymbolByName(const char *name, int typeidx) {

    if (lookupSymbol(name) != -1) {
        // Disallow duplicate names of two variables in the symbol table.Given in Problem statement 
        fprintf(stderr, "Error: Redeclaration of variable '%s'\n", name);
        return; 
    }

    if (ST_count >= MAX_SYMBOLS) { fprintf(stderr,"Symbol table overflow\n"); exit(1); }
    strncpy(ST[ST_count].name, name, sizeof(ST[ST_count].name)-1);
    ST[ST_count].name[sizeof(ST[ST_count].name)-1] = '\0';
    ST[ST_count].type = typeidx;
    ST[ST_count].offset = TT[typeidx].width;
    ST_count++;
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
    } else {
        snprintf(buf, buflen, "unknown");
    }
}

void printTypeTable(void) {
    printf("+++ %d types\n", TT_count);
    for (int i = 0; i < TT_count; ++i) {
        printf("    Type %3d: %8d    %s\n", i, TT[i].width, TT[i].name);
    }
    printf("\n");
}
void printSymbolTable(void) {
    printf("+++ Symbol table\n");
    int st_offset =0;
    int end_offset =0;
    for (int i = 0; i < ST_count; ++i) {
        char descr[512];
        end_offset = st_offset+ ST[i].offset-1;
        typeDescr_recursive(ST[i].type, descr, sizeof(descr));
        printf("    %-18s %4d - %4d         type = %4d = %s\n",
               ST[i].name, st_offset, end_offset , ST[i].type, descr);
        st_offset+= align4(ST[i].offset);
    }
    printf("    Total width = %d\n", st_offset);
}

/* main */
int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) { perror("fopen"); return 1; }
        extern FILE *yyin;
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

