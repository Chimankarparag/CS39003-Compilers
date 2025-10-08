%{
/* ctype.y - Yacc file with type table and symbol table implementation */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <stdint.h>

#define MAX_TYPES 1000
#define MAX_SYMBOLS 1000

/* categories */
#define CAT_BASIC 0
#define CAT_ARRAY 1
#define CAT_POINTER 2

typedef struct {
    int category;   /* BASIC/ARRAY/POINTER */
    int dim;        /* for ARRAY: element count; otherwise 0 */
    int ref;        /* index into TT of element/underlying type */
    size_t width;   /* in bytes */
    char name[128]; /* printable description */
} TypeRec;

TypeRec TT[MAX_TYPES];
int TT_size = 0;

typedef struct {
    char *name;
    int type;   /* index into TT */
    int start;  /* offset start */
    int end;    /* offset end */
} SymRec;

SymRec ST[MAX_SYMBOLS];
int ST_size = 0;




/* current width (next free offset). Always maintained as multiple of 4. */
int cur_width = 0;

/* current base type index for a declaration (set at start of each DECL) */
int curBaseType = -1;

/* helper for dims list used in semantic values */
typedef struct {
    int n;
    int *d;
} DimList;






void init_TT();
int add_basic_type(const char *name, size_t w);
int find_array_type(int dim, int elem);
int find_pointer_type(int elem);
int add_array_type(int dim, int elem);
int add_pointer_type(int elem);
void print_TT();
void add_symbol(const char *name, int typeidx);
void print_ST();
int align4(int x);

/* utility */
char *xstrdup(const char *s) { if (!s) return NULL; return strdup(s); }

/* For yylex interaction */
extern int yylex();
extern int yyparse();
extern FILE *yyin;
void yyerror(const char *s) { fprintf(stderr, "Parse error: %s\n", s); exit(1); }

%}

/* tell yacc the types */
%union {
    int ival;
    char *sval;
    DimList *dlist;
}

/* tokens (ID and NUM need values) */
%token VOID UCHR CHR SRT USRT LNG ULNG UINT INT FLT DBL
%token <sval> ID
%token <ival> NUM

%type <ival> BASIC PTR VAR DIM VARLIST
%type <dlist> DLIST

%start PROG

%%

PROG:
      DECLIST { printf("+++ All declarations read\n\n"); print_TT(); print_ST(); }
    ;

DECLIST:
      DECLIST DECL
    | DECL
    ;

DECL:
      BASIC { curBaseType = $1; } VARLIST ';'
    ;

BASIC:
      VOID   { $$ = 0; }
    | UCHR   { $$ = 1; }
    | CHR    { $$ = 2; }
    | USRT   { $$ = 3; }
    | SRT    { $$ = 4; }
    | ULNG   { $$ = 5; }
    | LNG    { $$ = 6; }
    | UINT   { $$ = 7; }
    | INT    { $$ = 8; }
    | FLT    { $$ = 9; }
    | DBL    { $$ = 10; }
    ;

VARLIST:
      VARLIST ',' VAR
    | VAR
    ;

VAR:
      PTR ID DIM
    {
        int base = curBaseType;
        int typeidx = base;
        int stars = $1;
        /* apply pointer constructions */
        for (int i = 0; i < stars; ++i) {
            typeidx = find_pointer_type(typeidx);
        }
        /* apply array dimensions, if any */
        if ($3 != NULL && $3->n > 0) {
            for (int i = $3->n - 1; i >= 0; --i) { /* from rightmost to leftmost */
                typeidx = find_array_type($3->d[i], typeidx);
            }
        }
        add_symbol($2, typeidx);
        free($2);
        if ($3) { free($3->d); free($3); }
    }
    ;

PTR:
      '*' PTR { $$ = $2 + 1; }
    | /* empty */ { $$ = 0; }
    ;

DIM:
      '[' NUM ']' DIM
    {
        /* build a dimlist: left-to-right */
        DimList *rest = $4;
        DimList *nl = (DimList *) malloc(sizeof(DimList));
        if (!rest) {
            nl->n = 1;
            nl->d = (int*) malloc(sizeof(int));
            nl->d[0] = $2;
        } else {
            nl->n = rest->n + 1;
            nl->d = (int*) malloc(sizeof(int) * nl->n);
            nl->d[0] = $2;
            for (int i = 0; i < rest->n; ++i) nl->d[i+1] = rest->d[i];
            free(rest->d); free(rest);
        }
        $$ = nl;
    }
    | /* empty */ { $$ = NULL; }
    ;

%%

/*---------------- Implementation of type table and symbol table ----------------*/

int align4(int x) {
    if (x % 4 == 0) return x;
    return x + (4 - (x % 4));
}

int add_basic_type(const char *name, size_t w) {
    int idx = TT_size++;
    TT[idx].category = CAT_BASIC;
    TT[idx].dim = 0;
    TT[idx].ref = -1;
    TT[idx].width = w;
    snprintf(TT[idx].name, sizeof(TT[idx].name), "%s", name);
    return idx;
}

void init_TT() {
    TT_size = 0;
    /* Insert basic types in the exact order expected by the sample output:
       0 void, 1 unsigned char, 2 char, 3 unsigned short, 4 short,
       5 unsigned long, 6 long, 7 unsigned int, 8 int, 9 float, 10 double
    */
    add_basic_type("void", 0);
    add_basic_type("unsigned char", sizeof(unsigned char));
    add_basic_type("char", sizeof(char));
    add_basic_type("unsigned short", sizeof(unsigned short));
    add_basic_type("short", sizeof(short));
    add_basic_type("unsigned long", sizeof(unsigned long));
    add_basic_type("long", sizeof(long));
    add_basic_type("unsigned int", sizeof(unsigned int));
    add_basic_type("int", sizeof(int));
    add_basic_type("float", sizeof(float));
    add_basic_type("double", sizeof(double));
}

/* search pointer type; if not present, add */
int find_pointer_type(int elem) {
    for (int i = 0; i < TT_size; ++i) {
        if (TT[i].category == CAT_POINTER && TT[i].ref == elem) return i;
    }
    return add_pointer_type(elem);
}

int add_pointer_type(int elem) {
    int idx = TT_size++;
    TT[idx].category = CAT_POINTER;
    TT[idx].dim = 0;
    TT[idx].ref = elem;
    TT[idx].width = sizeof(void *);
    snprintf(TT[idx].name, sizeof(TT[idx].name), "pointer(%s)", TT[elem].name);
    return idx;
}

/* search array type; if not present, add */
int find_array_type(int dim, int elem) {
    for (int i = 0; i < TT_size; ++i) {
        if (TT[i].category == CAT_ARRAY && TT[i].dim == dim && TT[i].ref == elem) return i;
    }
    return add_array_type(dim, elem);
}

int add_array_type(int dim, int elem) {
    int idx = TT_size++;
    TT[idx].category = CAT_ARRAY;
    TT[idx].dim = dim;
    TT[idx].ref = elem;
    TT[idx].width = (size_t) dim * TT[elem].width;
    snprintf(TT[idx].name, sizeof(TT[idx].name), "array(%d,%s)", dim, TT[elem].name);
    return idx;
}

void add_symbol(const char *name, int typeidx) {
    /* check duplicates */
    for (int i = 0; i < ST_size; ++i) {
        if (strcmp(ST[i].name, name) == 0) {
            fprintf(stderr, "Error: duplicate symbol '%s'\n", name);
            exit(1);
        }
    }
    int start = align4(cur_width);
    int end = start + (int)TT[typeidx].width - 1;
    ST[ST_size].name = xstrdup(name);
    ST[ST_size].type = typeidx;
    ST[ST_size].start = start;
    ST[ST_size].end = end;
    ST_size++;
    cur_width = end + 1;
    cur_width = align4(cur_width);
}

void print_TT() {
    printf("+++ %d types\n", TT_size);
    for (int i = 0; i < TT_size; ++i) {
        printf("    Type %3d: %8zu    %s\n", i, (size_t)TT[i].width, TT[i].name);
    }
    printf("\n");
}

void print_ST() {
    printf("+++ Symbol table\n");
    for (int i = 0; i < ST_size; ++i) {
        printf("    %-18s %4d - %4d        type = %4d = %s\n",
               ST[i].name, ST[i].start, ST[i].end, ST[i].type, TT[ST[i].type].name);
    }
    printf("    Total width = %d\n", cur_width);
}

/*---------------- main ----------------*/

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) { perror("fopen"); exit(1); }
    } else {
        yyin = stdin;
    }
    init_TT();
    /* initial offsets */
    ST_size = 0;
    cur_width = 0;
    yyparse();
    return 0;
}
