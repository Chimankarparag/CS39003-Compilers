%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
extern FILE *yyin;

#define MAX_TYPES 1000
#define MAX_SYMBOLS 1000

#define CAT_BASIC   0
#define CAT_ARRAY   1
#define CAT_POINTER 2

struct TypeEntry {
    int category;
    int dim;
    int ref;
    int width;
    char name[256];
};

struct SymEntry {
    char *name;
    int type;
    int start;
    int end;
};

struct TypeEntry TT[MAX_TYPES];
int TT_count = 0;

struct SymEntry ST[MAX_SYMBOLS];
int ST_count = 0;

int curr_base_type = -1;
int curr_offset = 0;
int working_type = 0;

void initTypeTable(void);
int addBasicType(const char *name, int width);
int findOrAddArrayType(int dim, int reftype);
int findOrAddPointerType(int reftype);
void addSymbolByName(const char *name, int typeidx);
int lookupSymbol(const char *name);
int align4(int x);
void typeDescr_recursive(int idx, char *buf, int buflen);
void printTypeTable(void);
void printSymbolTable(void);

%}

%union {
    int ival;
    char *sval;
}

%token <sval> ID
%token <ival> NUM

%token VOID UCHR CHR SRT USRT LNG ULNG UINT INT FLT DBL

%type <ival> BASIC

%start PROG

%%

PROG:
    DECLIST
    {
        printf("+++ All declarations read\n\n");
    }
    ;

DECLIST:
    DECLIST DECL
    | DECL
    ;

DECL:
    BASIC VARLIST ';'
    ;

BASIC:
    VOID  { curr_base_type = 0; $$ = curr_base_type; }
    | UCHR  { curr_base_type = 1; $$ = curr_base_type; }
    | CHR   { curr_base_type = 2;  $$ = curr_base_type; }
    | SRT   { curr_base_type = 3;  $$ = curr_base_type; }
    | USRT  { curr_base_type = 4; $$ = curr_base_type; }
    | LNG   { curr_base_type = 5;  $$ = curr_base_type; }
    | ULNG  { curr_base_type = 6; $$ = curr_base_type; }
    | UINT  { curr_base_type = 7; $$ = curr_base_type; }
    | INT   { curr_base_type = 8;  $$ = curr_base_type; }
    | FLT   { curr_base_type = 9;  $$ = curr_base_type; }
    | DBL   { curr_base_type = 10;  $$ = curr_base_type; }
    ;

VARLIST:
    VAR
    | VARLIST ',' VAR
    ;

VAR:
    { working_type = curr_base_type; }
    PTRS ID DIM
    {
        addSymbolByName($3, working_type);
        free($3);
    }
    ;

PTRS:
    | PTRS '*' { working_type = findOrAddPointerType(working_type); }
    ;

DIM:
    | '[' NUM ']' DIM { working_type = findOrAddArrayType($2, working_type); }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

void initTypeTable(void) {
    TT_count = 0;
    addBasicType("void", 0);
    addBasicType("unsigned char", (int)sizeof(unsigned char));
    addBasicType("char", (int)sizeof(char));
    addBasicType("short", (int)sizeof(short));
    addBasicType("unsigned short", (int)sizeof(unsigned short));
    addBasicType("long", (int)sizeof(long));
    addBasicType("unsigned long", (int)sizeof(unsigned long));
    addBasicType("unsigned int", (int)sizeof(unsigned int));
    addBasicType("int", (int)sizeof(int));
    addBasicType("float", (int)sizeof(float));
    addBasicType("double", (int)sizeof(double));
    
    curr_offset = 0;
}

int addBasicType(const char *name, int width) {
    if (TT_count >= MAX_TYPES) {
        fprintf(stderr, "Type table overflow\n");
        exit(1);
    }
    TT[TT_count].category = CAT_BASIC;
    TT[TT_count].dim = 0;
    TT[TT_count].ref = -1;
    TT[TT_count].width = width;
    strncpy(TT[TT_count].name, name, sizeof(TT[TT_count].name)-1);
    TT[TT_count].name[sizeof(TT[TT_count].name)-1] = '\0';
    TT_count++;
    return TT_count - 1;
}

int findOrAddArrayType(int dim, int reftype) {
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == CAT_ARRAY && TT[i].dim == dim && TT[i].ref == reftype)
            return i;
    }
    
    if (TT_count >= MAX_TYPES) {
        fprintf(stderr, "Type table overflow\n");
        exit(1);
    }
    TT[TT_count].category = CAT_ARRAY;
    TT[TT_count].dim = dim;
    TT[TT_count].ref = reftype;
    long long w = (long long)dim * (long long)TT[reftype].width;
    TT[TT_count].width = (int)w;
    
    char inner[256];
    typeDescr_recursive(reftype, inner, sizeof(inner));
    snprintf(TT[TT_count].name, sizeof(TT[TT_count].name), "array(%d,%s)", dim, inner);
    
    TT_count++;
    return TT_count - 1;
}

int findOrAddPointerType(int reftype) {
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == CAT_POINTER && TT[i].ref == reftype)
            return i;
    }
    
    if (TT_count >= MAX_TYPES) {
        fprintf(stderr, "Type table overflow\n");
        exit(1);
    }
    TT[TT_count].category = CAT_POINTER;
    TT[TT_count].dim = 0;
    TT[TT_count].ref = reftype;
    TT[TT_count].width = (int)sizeof(void *);
    
    char inner[256];
    typeDescr_recursive(reftype, inner, sizeof(inner));
    snprintf(TT[TT_count].name, sizeof(TT[TT_count].name), "pointer(%s)", inner);
    
    TT_count++;
    return TT_count - 1;
}

void addSymbolByName(const char *name, int typeidx) {
    if (ST_count >= MAX_SYMBOLS) {
        fprintf(stderr, "Symbol table overflow\n");
        exit(1);
    }
    if (lookupSymbol(name) != -1) {
        fprintf(stderr, "Error: duplicate symbol '%s' ignored\n", name);
        return;
    }
    int start = curr_offset;
    int width = TT[typeidx].width;
    int end = start + width - 1;
    ST[ST_count].name = strdup(name);
    ST[ST_count].type = typeidx;
    ST[ST_count].start = start;
    ST[ST_count].end = end;
    ST_count++;
    curr_offset = align4(end + 1);
}

int lookupSymbol(const char *name) {
    for (int i = 0; i < ST_count; ++i) {
        if (strcmp(ST[i].name, name) == 0) return i;
    }
    return -1;
}

int align4(int x) {
    if (x % 4 == 0) return x;
    return x + (4 - (x % 4));
}

void typeDescr_recursive(int idx, char *buf, int buflen) {
    if (idx < 0 || idx >= TT_count) {
        snprintf(buf, buflen, "??");
        return;
    }
    if (TT[idx].category == CAT_BASIC) {
        snprintf(buf, buflen, "%s", TT[idx].name);
    } else if (TT[idx].category == CAT_POINTER) {
        char inner[256];
        typeDescr_recursive(TT[idx].ref, inner, sizeof(inner));
        snprintf(buf, buflen, "pointer(%s)", inner);
    } else if (TT[idx].category == CAT_ARRAY) {
        char inner[256];
        typeDescr_recursive(TT[idx].ref, inner, sizeof(inner));
        snprintf(buf, buflen, "array(%d,%s)", TT[idx].dim, inner);
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
    for (int i = 0; i < ST_count; ++i) {
        char descr[512];
        typeDescr_recursive(ST[i].type, descr, sizeof(descr));
        printf("    %-18s %4d - %4d         type = %4d = %s\n",
               ST[i].name,
               ST[i].start,
               ST[i].end,
               ST[i].type,
               descr);
    }
    printf("    Total width = %d\n", curr_offset);
}

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) {
            perror("fopen");
            return 1;
        }
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