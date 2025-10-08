%{
/* C header section */
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

struct DimList {
    int val;
    struct DimList *next;
};

struct VarAttr {
    char *name;
    int type; 
};

struct TypeEntry {
    int category;   /* CAT_BASIC / CAT_ARRAY / CAT_POINTER */
    int dim;        /* for ARRAY: number of elements; else 0 */
    int ref;        /* index in TT of element type (for ARRAY/POINTER) */
    int width;      /* width in bytes */
    char name[256]; /* human readable description */
};


struct SymEntry {
    char *name;
    int type;   /* index in TypeTable */
    int start;  /* start offset */
    int end;    /* end offset */
};

/* Global tables */
struct TypeEntry TT[MAX_TYPES];
int TT_count = 0;

struct SymEntry ST[MAX_SYMBOLS];
int ST_count = 0;

/* Global current base type (index into TT) for the current DECL */
int curr_base_type = -1;

/* Global current width/offset (maintained as next-start multiple-of-4) */
int curr_offset = 0;

/* Helper prototypes */
void initTypeTable(void);
int addBasicType(const char *name, int width);
int findType_array(int dim, int reftype);
int findType_pointer(int reftype);
int addArrayType(int dim, int reftype);
int addPointerType(int reftype);
int applyDims(struct DimList *d, int base_type);

void addSymbolByName(const char *name, int typeidx);
int lookupSymbol(const char *name);
int align4(int x);

void printTypeTable(void);
void printSymbolTable(void);

/* Helpers to create/destroy DimList and VarAttr */
struct DimList *newDimNode(int val, struct DimList *next);
void freeDimList(struct DimList *d);
struct VarAttr *newVarAttr(const char *name, int type);
void freeVarAttr(struct VarAttr *v);

/* For printing type description string */
void typeDescr_recursive(int idx, char *buf, int buflen);

%}

/* Bison declarations */
%union {
    int ival;                /* numbers, type indices */
    char *sval;              /* IDs */
    struct DimList *dval;    /* DIM linked list */
    struct VarAttr *vval;    /* VAR attribute (name + type) */
}

%token <sval> ID
%token <ival> NUM

/* basic type tokens produced by lex */
%token VOID UCHR CHR SRT USRT LNG ULNG UINT INT FLT DBL

/* Nonterminals with typed semantic values */
%type <ival> BASIC PTRS
%type <dval> DIM
%type <vval> VAR
%type <vval> VARLIST

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
    {
    }
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
    {
        addSymbolByName($1->name, $1->type);
        freeVarAttr($1);
        $$ = NULL;
    }
    | VARLIST ',' VAR
    {
        addSymbolByName($3->name, $3->type);
        freeVarAttr($3);
        $$ = NULL;
    }
    ;

PTRS:
      '*' PTRS   { $$ = $2 + 1; }
    | /* empty */ { $$ = 0; }
    ;

VAR:
      PTRS ID DIM
    {
        int base = curr_base_type;
        int i;

        /* wrap base with pointers (from leftmost star to rightmost) */
        for (i = 0; i < $1; ++i) {
            base = addPointerType(base);
        }


        base = applyDims($3, base);

        $$ = newVarAttr($2, base);

        freeDimList($3);
    }
    ;

DIM:
      '[' NUM ']' DIM  { $$ = newDimNode($2, $4); }
    | /* empty */       { $$ = NULL; }
    ;

%%

/* ------------------ C helper functions ------------------ */

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

/* DimList helpers */
struct DimList *newDimNode(int val, struct DimList *next) {
    struct DimList *n = (struct DimList*)malloc(sizeof(struct DimList));
    if (!n) { perror("malloc"); exit(1); }
    n->val = val;
    n->next = next;
    return n;
}
void freeDimList(struct DimList *d) {
    while (d) {
        struct DimList *t = d->next;
        free(d);
        d = t;
    }
}

/* VarAttr helpers */
struct VarAttr *newVarAttr(const char *name, int type) {
    struct VarAttr *v = (struct VarAttr*)malloc(sizeof(struct VarAttr));
    if (!v) { perror("malloc"); exit(1); }
    v->name = strdup(name);
    v->type = type;
    return v;
}
void freeVarAttr(struct VarAttr *v) {
    if (!v) return;
    if (v->name) free(v->name);
    free(v);
}

/* Initialize base types (in the same order used in assignment sample) */
void initTypeTable(void) {
    TT_count = 0;
    addBasicType("void", 0); /* 0 */
    addBasicType("unsigned char", (int)sizeof(unsigned char)); /* 1 */
    addBasicType("char", (int)sizeof(char)); /* 2 */
    addBasicType("unsigned short", (int)sizeof(unsigned short)); /* 3 */
    addBasicType("short", (int)sizeof(short)); /* 4 */
    addBasicType("unsigned long", (int)sizeof(unsigned long)); /* 5 */
    addBasicType("long", (int)sizeof(long)); /* 6 */
    addBasicType("unsigned int", (int)sizeof(unsigned int)); /* 7 */
    addBasicType("int", (int)sizeof(int)); /* 8 */
    addBasicType("float", (int)sizeof(float)); /* 9 */
    addBasicType("double", (int)sizeof(double)); /* 10 */

    curr_offset = 0;
}

/* Add a basic type entry; return its index */
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

/* Find existing array type (linear search) */
int findType_array(int dim, int reftype) {
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == CAT_ARRAY && TT[i].dim == dim && TT[i].ref == reftype)
            return i;
    }
    return -1;
}

/* Find existing pointer type (linear search) */
int findType_pointer(int reftype) {
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == CAT_POINTER && TT[i].ref == reftype)
            return i;
    }
    return -1;
}

/* Add array type (if not present); returns index */
int addArrayType(int dim, int reftype) {
    int idx = findType_array(dim, reftype);
    if (idx != -1) return idx;
    if (TT_count >= MAX_TYPES) {
        fprintf(stderr, "Type table overflow\n");
        exit(1);
    }
    TT[TT_count].category = CAT_ARRAY;
    TT[TT_count].dim = dim;
    TT[TT_count].ref = reftype;
    long long w = (long long)dim * (long long)TT[reftype].width;
    TT[TT_count].width = (int)w;
    /* build name */
    {
        char inner[256];
        typeDescr_recursive(reftype, inner, sizeof(inner));
        snprintf(TT[TT_count].name, sizeof(TT[TT_count].name), "array(%d,%s)", dim, inner);
    }
    TT_count++;
    return TT_count - 1;
}

/* Add pointer type (if not present); returns index */
int addPointerType(int reftype) {
    int idx = findType_pointer(reftype);
    if (idx != -1) return idx;
    if (TT_count >= MAX_TYPES) {
        fprintf(stderr, "Type table overflow\n");
        exit(1);
    }
    TT[TT_count].category = CAT_POINTER;
    TT[TT_count].dim = 0;
    TT[TT_count].ref = reftype;
    TT[TT_count].width = (int)sizeof(void *);
    {
        char inner[256];
        typeDescr_recursive(reftype, inner, sizeof(inner));
        snprintf(TT[TT_count].name, sizeof(TT[TT_count].name), "pointer(%s)", inner);
    }
    TT_count++;
    return TT_count - 1;
}

/* Symbol table: add symbol with type index, compute offsets, align to 4 */
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

/* Apply dimensions from right->left:
   If DIM is [d1] -> [d2] -> ... (as stored), apply recursively. */
int applyDims(struct DimList *d, int base_type) {
    if (d == NULL) return base_type;
    int inner = applyDims(d->next, base_type);
    return addArrayType(d->val, inner);
}

/* Build type description recursively for printing */
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

/* Print type table and symbol table */
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


/* -------------------- main -------------------- */
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
        /* After parse success, print tables */
        printTypeTable();
        printSymbolTable();
    } else {
        fprintf(stderr, "Parsing failed\n");
    }
    return 0;
}
