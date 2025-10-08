%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern FILE *yyin ;
extern int yyparse();
int yylex() ;
void yyerror ( const char *s ){ fprintf(stderr, "Parse error: %s\n", s); exit(1); }  ;

#define BASE 0
#define ARR 1
#define PTR 2

#define MAX_TYPES 2048
#define MAX_SYMBOLS 2048


//struct for type table
typedef struct {
    int category; // base arr ptr
    int dimension; 
    int reference; 
    size_t width;
    char* name;
}Type_used;

Type_used TT[MAX_TYPES];
int TT_size = 0;

//struct for declaration
typedef struct {
    char* name;
    int type;
    int offset; // this is where i start 
    int width; // original length of the variable
}Sym_used;

Sym_used ST[MAX_SYMBOLS];  
int ST_size = 0;


//NOW for maintaining the offsets and widths 
int cur_width = 0;
int curBaseType = -1;

typedef struct{
    int n;
    int *d;
}DimensionList;

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

char *check_empty_strdup(const char *s) { if (!s) return NULL; return strdup(s); }

%}


%union{
    int ival;
    char* sval;
    struct DimensionList *dval;
}

%token<ival> NUM
%token<sval> ID
%token USRT SRT ULNG LNG UINT VOID UCHR CHR INT FLT DBL

%type<ival> BASIC VAR DIM VARLIST
%type<ival> M2
%type<dval> DLIST


%start PROG

%%

PROG:   DECLIST {printf("+++ All declarations read\n\n"); print_TT(); print_ST(); }
    ;

DECLIST:
        DECL DECLIST
    |   DECL
    ;

DECL:   BASIC { curBaseType = $1 } VARLIST ';'
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

VARLIST:    VARLIST ',' VAR
    |   VAR
    ;

VAR:    M2 ID DIM    
    
    {
        int base = curBaseType;
        int typeidx = base;
        int pointers = $1;
        for (int i = 0; i < pointers; ++i) {
            typeidx = find_pointer_type(typeidx);
        }
        if ($3 != NULL && $3->n > 0) {
            for (int i = $3->n - 1; i >= 0; --i) { 
                typeidx = find_array_type($3->d[i], typeidx);
            }
        }
        add_symbol($2, typeidx);
        free($2);
        if ($3) { free($3->d); free($3); }
    }
    ;

M2:
      '*' M2 { $$ = $2 + 1; }
    | { $$ = 0; } // EPSILON
    ;

DIM:
      '[' NUM ']' DIM
    {
        DimensionList *rest = $4;
        DimensionList *nl = (DimensionList *) malloc(sizeof(DimensionList));
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
    | { $$ = NULL; } // EPSILON
    ;

%%

int align4(int x){
    return (x + 3) & ~3;
}

int add_basic_type(const char *name, size_t w){
    int idx = TT_size++;
    if (TT_size >= MAX_TYPES) {
        fprintf(stderr, "Type Table overflow\n");
        exit(1);
    }
    TT[idx].category = BASE;
    //check and update later if category should be the name 
    TT[idx].dimension = 0;
    TT[idx].reference = -1;
    TT[idx].width = w;
    TT[idx].name = check_empty_strdup(name);
    return idx;
}

void init_TT() {
    TT_size = 0;
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

int find_pointer_type(int elem) {
    for (int i = 0; i < TT_size; ++i) {
        if (TT[i].category == PTR && TT[i].reference == elem) return i;
    }
    return add_pointer_type(elem);
}

int add_pointer_type(int elem) {
    int idx = TT_size++;
    if(TT_size >= MAX_TYPES){
        fprint(stderr, "Type table overflow");
        exit(1);
    }
    TT[idx].category = PTR;
    TT[idx].dimension = 0;
    TT[idx].reference = elem;
    TT[idx].width = sizeof(void *);
    return idx;
}

int find_array_type(int dim, int elem) {
    for (int i = 0; i < TT_size; ++i) {
        if (TT[i].category == ARR && TT[i].dimension == dim && TT[i].reference == elem) return i;
    }
    return add_array_type(dim, elem);
}

int add_array_type(int dim, int elem) {
    int idx = TT_size++;
    if (TT_size >= MAX_TYPES) {
        fprintf(stderr, "Type Table overflow\n");
        exit(1);
    }
    TT[idx].category = ARR;
    TT[idx].dimension = dim;
    TT[idx].reference = elem;
    TT[idx].width = (size_t) dim * TT[elem].width;
    return idx;
}

void add_symbol(const char *name, int typeidx) {
    for (int i = 0; i < ST_size; ++i) {
        if (strcmp(ST[i].name, name) == 0) {
            fprintf(stderr, "Error: duplicate symbol '%s'\n", name);
            exit(1);
        }
    }
    int start = align4(cur_width);
    int end = start + (int)TT[typeidx].width - 1;
    ST[ST_size].name = check_empty_strdup(name);
    ST[ST_size].type = typeidx;
    ST[ST_size].offset = start;
    ST[ST_size].width = end;
    ST_size++;
    cur_width = end + 1;
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

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) { perror("fopen"); exit(1); }
    } else {
        yyin = stdin;
    }
    init_TT();
    ST_size = 0;
    cur_width = 0;
    yyparse();
    return 0;
}
