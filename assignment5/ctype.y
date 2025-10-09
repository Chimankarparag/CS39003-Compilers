%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXTYPES 200
#define MAXSYMS 200

typedef struct {
    int k;
    int sz;
    int b;
    int d;
} TInfo;

typedef struct {
    char *n;
    int t;
    int o;
} SInfo;

TInfo TBL[MAXTYPES];
int tcount = 0;
SInfo SYM[MAXSYMS];
int scount = 0;

int curOff = 0;
int baseT = 0;
int curT = 0;

int newArr(int dim, int subtype);
int newPtr(int subtype);
void addSym(const char *name, int typeIndex);
void showT(int idx);
void showTBL(void);
void showSYM(void);

void initTBL(void);
int yyerror(const char *s);
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
%token '*' ',' ';' '[' ']'
%type <tid> VAR DIM

%%

PROG:
    DECLS
    ;

DECLS:
    DECLS DECL
  | DECL
    ;

DECL:
    BASE VARLIST ';'
    ;

BASE:
    VOID   { baseT = 0; }
  | UCHR   { baseT = 1; }
  | CHR    { baseT = 2; }
  | USRT   { baseT = 3; }
  | SRT    { baseT = 4; }
  | ULNG   { baseT = 5; }
  | LNG    { baseT = 6; }
  | UINT   { baseT = 7; }
  | INT    { baseT = 8; }
  | FLT    { baseT = 9; }
  | DBL    { baseT = 10; }
    ;

VARLIST:
    VAR
  | VARLIST ',' VAR
    ;

VAR:
    { curT = baseT; }
    STARS id DIM {
        addSym($3, curT);
        $$ = curT;
    }
    ;

STARS:
    /* empty */
  | STARS '*' { curT = newPtr(curT); }
    ;

DIM:
    /* empty */ { $$ = curT; }
  | '[' num ']' DIM {
        curT = newArr($2, curT);
        $$ = curT;
    }
    ;

%%

void initTBL(void) {
    int s[] = {0,1,1,2,2,8,8,4,4,4,8};
    for (int i=0;i<11;i++){ TBL[i].k=0; TBL[i].sz=s[i]; }
    tcount = 11;
}

int newArr(int dim, int subtype) {
    for (int i = 0; i < tcount; ++i)
        if (TBL[i].k == 2 && TBL[i].d == dim && TBL[i].b == subtype)
            return i;
    TBL[tcount].k = 2;
    TBL[tcount].d = dim;
    TBL[tcount].b = subtype;
    TBL[tcount].sz = dim * TBL[subtype].sz;
    return tcount++;
}

int newPtr(int subtype) {
    for (int i = 0; i < tcount; ++i)
        if (TBL[i].k == 1 && TBL[i].b == subtype)
            return i;
    TBL[tcount].k = 1;
    TBL[tcount].b = subtype;
    TBL[tcount].sz = 8;
    return tcount++;
}

void addSym(const char *name, int typeIndex) {
    if (curOff % 4 != 0) curOff += (4 - (curOff % 4));
    SYM[scount].n = strdup(name);
    SYM[scount].t = typeIndex;
    SYM[scount].o = curOff;
    curOff += TBL[typeIndex].sz;
    scount++;
}

void showT(int idx) {
    if (idx < 0 || idx >= tcount) { 
        printf("\t<?%d?>", idx); 
        return; 
    }
    TInfo *t = &TBL[idx];
    if (t->k == 0) {
        const char *nm[11] = {
            "void","unsigned char","char","unsigned short",
            "short","unsigned long","long","unsigned int",
            "int","float","double"
        };
        if (idx <= 10) printf("%s", nm[idx]);
        else printf("basic(%d)", idx);
    } else if (t->k == 1) {
        printf("pointer(");
        showT(t->b);
        printf(")");
    } else if (t->k == 2) {
        printf("array(%d,", t->d);
        showT(t->b);
        printf(")");
    } else {
        printf("unknown");
    }
}

void showTBL(void) {
    printf("+++ %d types\n", tcount);
    for (int i = 0; i < tcount; ++i) {
        printf("\tType %-2d:\t%-4d ", i, TBL[i].sz);
        showT(i);
        printf("\n");
    }
}

void showSYM(void) {
    printf("\n+++ Symbol table\n");
    for (int i = 0; i < scount; ++i) {
        int s = SYM[i].o;
        int e = SYM[i].o + TBL[SYM[i].t].sz - 1;
        printf("\t%-10s %4d - %-4d \ttype = %-2d = ", SYM[i].n, s, e, SYM[i].t);
        showT(SYM[i].t);
        printf("\n");
    }

    int tot = curOff;
    if (tot % 4 != 0) tot += (4 - (tot % 4));
    printf("\tTotal width = %d\n", tot);
}

int yyerror(const char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
    return 0;
}

int main(int argc, char **argv) {
    initTBL();
    if (argc > 1) yyin = fopen(argv[1], "r");
    yyparse();
    printf("+++ All declarations read\n\n");
    showTBL();
    showSYM();
    return 0;
}
