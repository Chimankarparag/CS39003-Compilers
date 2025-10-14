%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylineno;
int yyerror(const char *s);

#define MAXTYPES 2000
#define MAX_SYMTABS 200
#define MAXSYMS 2000

typedef enum { K_BASIC=0, K_PTR=1, K_ARR=2, K_STRUCT=3 } Kind;

typedef struct {
    Kind kind;
    int dim;
    int ref;    /* index to base/elem or symbol table for struct */
    int width;
    char *name;
} TypeRec;

typedef struct {
    char *name;
    int typeIndex;
    int offset;
} SymRec;

TypeRec TYPE_TABLE[MAXTYPES];
int typeCount = 0;

SymRec SYMTAB[MAX_SYMTABS][MAXSYMS];
int symCount[MAX_SYMTABS];
int symWidth[MAX_SYMTABS];
int nextTab = 1;

int currTab = 0;

int structTidStack[256];
int prevTabStack[256];
int structTop = -1;

int prevBaseStack[256];
int prevBaseTop = -1;

int baseType = 0;
int currType = 0;

/* prototypes */
void initTT(void);
int newArr(int dim, int subtype);
int newPtr(int subtype);
int add_struct_type(const char *sname, int symtabno);
int find_struct_type(const char *sname);
int new_symtab(void);
void insert_sym(const char *name, int symtabno, int typeIndex);
void showTT(void);
void showSYMS(void);
void showType(int idx);
int find_struct_by_symtab(int symtabno);

extern FILE *yyin;
int yylex(void);
%}

%union {
    int ival;
    char *sval;
    int tid;
}

%token <sval> id
%token <ival> num
%token VOID UCHR CHR SRT USRT LNG ULNG UINT INT FLT DBL
%token STRUCT
%token '{' '}' '[' ']' '*' ',' ';'

%type <tid> STRUCTDEF

%%

PROG:
    DECLS
    ;

DECLS:
    | DECLS DECL
    ;

DECL:
    BASE VARLIST ';'
  |
    STRUCTDEF ';'
  |
    STRUCTDEF
    {
        baseType = $1;
    }
    VARLIST_NONEMPTY ';'
  |
    STRUCT id
    {
        int idx = find_struct_type($2);
        if (idx < 0) { yyerror("use of undefined struct type"); baseType = 0; } else baseType = idx;
    }
    VARLIST ';'
    ;

STRUCTDEF:
    STRUCT id '{'
    {
        int stno = new_symtab();
        int tid = add_struct_type($2, stno);
        if (structTop + 1 >= (int)(sizeof(structTidStack)/sizeof(structTidStack[0])))
            yyerror("struct nesting too deep");
        structTidStack[++structTop] = tid;
        prevTabStack[structTop] = currTab;
        currTab = stno;
    }
    MEMBER_LIST
    '}'
    {
        int tid = structTidStack[structTop];
        int stno = TYPE_TABLE[tid].ref;
        int w = symWidth[stno];
        if (w % 4 != 0) w += (4 - (w % 4));
        TYPE_TABLE[tid].width = w;
        currTab = prevTabStack[structTop];
        structTop--;
        $$ = tid;
    }
    ;

BASE:
    VOID   { baseType = 0; }
  | UCHR   { baseType = 1; }
  | CHR    { baseType = 2; }
  | USRT   { baseType = 3; }
  | SRT    { baseType = 4; }
  | ULNG   { baseType = 5; }
  | LNG    { baseType = 6; }
  | UINT   { baseType = 7; }
  | INT    { baseType = 8; }
  | FLT    { baseType = 9; }
  | DBL    { baseType = 10; }
    ;

VARLIST:
    | VARLIST_NONEMPTY
    ;

VARLIST_NONEMPTY:
    VAR
  | VARLIST_NONEMPTY ',' VAR
    ;

MEMBER_LIST:
    | MEMBER_LIST MEMBER
    ;

MEMBER:
    BASE VARLIST_NONEMPTY ';'
  |
    STRUCTDEF
    {
        if (prevBaseTop + 1 >= (int)(sizeof(prevBaseStack)/sizeof(prevBaseStack[0])))
            yyerror("baseT nesting too deep");
        prevBaseStack[++prevBaseTop] = baseType;
        baseType = $1;
    }
    VARLIST_NONEMPTY ';'
    {
        baseType = prevBaseStack[prevBaseTop--];
    }
  |
    STRUCT id
    {
        int idx = find_struct_type($2);
        if (idx < 0) {
            yyerror("use of undefined struct type in member");
            idx = 0;
        }
        if (prevBaseTop + 1 >= (int)(sizeof(prevBaseStack)/sizeof(prevBaseStack[0])))
            yyerror("baseT nesting too deep");
        prevBaseStack[++prevBaseTop] = baseType;
        baseType = idx;
    }
    VARLIST_NONEMPTY ';'
    {
        baseType = prevBaseStack[prevBaseTop--];
    }
    ;

VAR:
    { currType = baseType; }
    STARS id DIM
    {
        insert_sym($3, currTab, currType);
    }
    ;

STARS:
    | STARS '*' { currType = newPtr(currType); }
    ;

DIM:
    { }
  | '[' num ']' DIM { currType = newArr($2, currType); }
    ;

%%

/* implementation */

void initTT(void) {
    int sizes[] = {0,1,1,2,2,8,8,4,4,4,8};
    const char *names[] = {"void","unsigned char","char","unsigned short","short","unsigned long","long","unsigned int","int","float","double"};
    for (int i = 0; i < 11; ++i) {
        TYPE_TABLE[i].kind = K_BASIC;
        TYPE_TABLE[i].dim = 0;
        TYPE_TABLE[i].ref = 0;
        TYPE_TABLE[i].width = sizes[i];
        TYPE_TABLE[i].name = strdup(names[i]);
    }
    typeCount = 11;
    for (int i=0;i<MAX_SYMTABS;i++) { symCount[i]=0; symWidth[i]=0; }
    currTab = 0;
    nextTab = 1;
    structTop = -1;
    prevBaseTop = -1;
}

int newArr(int dim, int subtype) {
    if (subtype < 0 || subtype >= typeCount) {
        yyerror("invalid subtype for array");
        return 0;
    }
    for (int i = 0; i < typeCount; ++i)
        if (TYPE_TABLE[i].kind == K_ARR && TYPE_TABLE[i].dim == dim && TYPE_TABLE[i].ref == subtype) return i;
    TYPE_TABLE[typeCount].kind = K_ARR;
    TYPE_TABLE[typeCount].dim = dim;
    TYPE_TABLE[typeCount].ref = subtype;
    TYPE_TABLE[typeCount].width = dim * TYPE_TABLE[subtype].width;
    TYPE_TABLE[typeCount].name = NULL;
    return typeCount++;
}

int newPtr(int subtype) {
    for (int i = 0; i < typeCount; ++i)
        if (TYPE_TABLE[i].kind == K_PTR && TYPE_TABLE[i].ref == subtype) return i;
    TYPE_TABLE[typeCount].kind = K_PTR;
    TYPE_TABLE[typeCount].ref = subtype;
    TYPE_TABLE[typeCount].dim = 0;
    TYPE_TABLE[typeCount].width = 8;
    TYPE_TABLE[typeCount].name = NULL;
    return typeCount++;
}

int add_struct_type(const char *sname, int symtabno) {
    for (int i = 0; i < typeCount; ++i)
        if (TYPE_TABLE[i].kind == K_STRUCT && TYPE_TABLE[i].name && strcmp(TYPE_TABLE[i].name, sname) == 0) {
            yyerror("redefinition of struct");
            return i;
        }
    TYPE_TABLE[typeCount].kind = K_STRUCT;
    TYPE_TABLE[typeCount].ref = symtabno;
    TYPE_TABLE[typeCount].dim = 0;
    TYPE_TABLE[typeCount].width = 0;
    TYPE_TABLE[typeCount].name = strdup(sname);
    return typeCount++;
}

int find_struct_type(const char *sname) {
    for (int i = 0; i < typeCount; ++i)
        if (TYPE_TABLE[i].kind == K_STRUCT && TYPE_TABLE[i].name && strcmp(TYPE_TABLE[i].name, sname) == 0) return i;
    return -1;
}

int new_symtab(void) {
    int n = nextTab++;
    if (n >= MAX_SYMTABS) {
        yyerror("too many symbol tables");
        return 0;
    }
    symCount[n] = 0;
    symWidth[n] = 0;
    return n;
}

void insert_sym(const char *name, int symtabno, int typeIndex) {
    for (int i = 0; i < symCount[symtabno]; ++i)
        if (strcmp(SYMTAB[symtabno][i].name, name) == 0) {
            fprintf(stderr, "Error: duplicate name '%s' in symbol table %d\n", name, symtabno);
            return;
        }
    int off = symWidth[symtabno];
    if (off % 4 != 0) off += (4 - (off % 4));
    SYMTAB[symtabno][symCount[symtabno]].name = strdup(name);
    SYMTAB[symtabno][symCount[symtabno]].typeIndex = typeIndex;
    SYMTAB[symtabno][symCount[symtabno]].offset = off;
    symCount[symtabno]++;
    int addw = TYPE_TABLE[typeIndex].width;
    if (addw <= 0) {
        if (TYPE_TABLE[typeIndex].kind == K_STRUCT) {
            fprintf(stderr, "Error: use of incomplete struct type '%s' for variable '%s' in symtab %d\n", TYPE_TABLE[typeIndex].name, name, symtabno);
            addw = 0;
        }
    }
    symWidth[symtabno] = off + addw;
}

void showType(int idx) {
    if (idx < 0 || idx >= typeCount) {
        printf("\t<?%d?>", idx);
        return;
    }
    TypeRec *t = &TYPE_TABLE[idx];
    if (t->kind == K_BASIC) {
        if (t->name) printf("%s", t->name);
        else printf("basic(%d)", idx);
    } else if (t->kind == K_PTR) {
        printf("pointer(");
        showType(t->ref);
        printf(")");
    } else if (t->kind == K_ARR) {
        printf("array(%d,", t->dim);
        showType(t->ref);
        printf(")");
    } else if (t->kind == K_STRUCT) {
        printf("struct %s with symbol table %d", t->name?t->name:"?", t->ref);
    } else {
        printf("unknown");
    }
}

int find_struct_by_symtab(int symtabno) {
    for (int i = 0; i < typeCount; ++i)
        if (TYPE_TABLE[i].kind == K_STRUCT && TYPE_TABLE[i].ref == symtabno) return i;
    return -1;
}

void showTT(void) {
    printf("+++ %d types\n", typeCount);
    for (int i = 0; i < typeCount; ++i) {
        printf("Type %d: %d ", i, TYPE_TABLE[i].width);
        showType(i);
        printf("\n");
    }
}

void showSYMS(void) {
    for (int st = 0; st < nextTab; ++st) {
        if (st == 0) printf("\n+++ Symbol table %d [main]\n", st);
        else {
            int tid = find_struct_by_symtab(st);
            if (tid >= 0) printf("\n+++ Symbol table %d [struct %s]\n", st, TYPE_TABLE[tid].name?TYPE_TABLE[tid].name:"?");
            else printf("\n+++ Symbol table %d\n", st);
        }
        if (symCount[st] == 0) { printf("    (empty)\n"); continue; }
        for (int i = 0; i < symCount[st]; ++i) {
            int s = SYMTAB[st][i].offset;
            int width = TYPE_TABLE[ SYMTAB[st][i].typeIndex ].width;
            int e = SYMTAB[st][i].offset + (width>0?width:0) - 1;
            printf("%-20s %4d - %4d \ttype = %4d = ", SYMTAB[st][i].name, s, e, SYMTAB[st][i].typeIndex);
            showType(SYMTAB[st][i].typeIndex);
            printf("\n");
        }
        int tot = symWidth[st];
        if (tot % 4 != 0) tot += (4 - (tot % 4));
        printf("Total width = %d\n", tot);
    }
}

int yyerror(const char *s) {
    fprintf(stderr, "Syntax error at line %d: %s\n", yylineno, s);
    return 0;
}

int main(int argc, char **argv) {
    initTT();
    if (argc > 1) yyin = fopen(argv[1], "r");
    yyparse();
    printf("+++ All declarations read\n\n");
    showTT();
    showSYMS();
    return 0;
}
