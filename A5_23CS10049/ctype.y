%{
/* C header section */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

int yylex(void);
void yyerror(const char *s);

#define MAX_TYPES 1000
#define MAX_SYMBOLS 1000

/* Type categories */
#define CAT_BASIC 0
#define CAT_ARRAY 1
#define CAT_POINTER 2

/* Structures used by parser semantic values */
struct DimList {
    int val;
    struct DimList *next;
};

struct VarAttr {
    char *name;
    int type; /* index in TypeTable */
};

/* Type table entry */
struct TypeEntry {
    int category;   /* CAT_BASIC / CAT_ARRAY / CAT_POINTER */
    int dim;        /* for ARRAY: number of elements; for others: 0 */
    int ref;        /* index in TT of element type (for ARRAY/POINTER) */
    int width;      /* width in bytes */
    /* for basic types we store a string name for printing */
    char name[128];
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
int same_array(int t1, int dim, int reftype);
int same_pointer(int t1, int reftype);
int getBasicIndexByToken(int tok); /* mapping tokens to indices after init */
int applyDims(struct DimList *d, int base_type);
int insertPointerAtBase(int typeidx);


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

/* Token -> basic type mapping helper: implemented after TT init */
int token_to_basic_index(int tok);

/* For printing type description string */
void typeDescr_recursive(int idx, char *buf, int buflen);

%}

/* Tell bison the tokens and the union types we use */
%union {
    int ival;                /* numbers, type indices */
    char *sval;              /* IDs */
    struct DimList *dval;    /* DIM linked list */
    struct VarAttr *vval;    /* VAR attribute (name + type) */
}

/* Tokens */
%token <sval> ID
%token <ival> NUM

%token VOID UCHR CHR SRT USRT LNG ULNG UINT INT FLT DBL

/* Nonterminals with typed semantic values */
%type <ival> BASIC
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
        /* After BASIC reduced, curr_base_type was set by BASIC's action.
           VARLIST actions already add symbols using curr_base_type semantics. */
    }
    ;

/* BASIC returns a type index in $1 and sets curr_base_type */
BASIC:
      VOID  { curr_base_type = token_to_basic_index(VOID); $$ = curr_base_type; }
    | UCHR  { curr_base_type = token_to_basic_index(UCHR); $$ = curr_base_type; }
    | CHR   { curr_base_type = token_to_basic_index(CHR);  $$ = curr_base_type; }
    | SRT   { curr_base_type = token_to_basic_index(SRT);  $$ = curr_base_type; }
    | USRT  { curr_base_type = token_to_basic_index(USRT); $$ = curr_base_type; }
    | LNG   { curr_base_type = token_to_basic_index(LNG);  $$ = curr_base_type; }
    | ULNG  { curr_base_type = token_to_basic_index(ULNG); $$ = curr_base_type; }
    | UINT  { curr_base_type = token_to_basic_index(UINT); $$ = curr_base_type; }
    | INT   { curr_base_type = token_to_basic_index(INT);  $$ = curr_base_type; }
    | FLT   { curr_base_type = token_to_basic_index(FLT);  $$ = curr_base_type; }
    | DBL   { curr_base_type = token_to_basic_index(DBL);  $$ = curr_base_type; }
    ;

/* VARLIST: process each VAR at top-level (so symbol insertion happens here) */
VARLIST:
      VAR
    {
        /* insert symbol for the top-level VAR */
        addSymbolByName($1->name, $1->type);
        freeVarAttr($1);
        $$ = NULL; /* not used */
    }
    | VARLIST ',' VAR
    {
        addSymbolByName($3->name, $3->type);
        freeVarAttr($3);
        $$ = NULL;
    }
    ;

/* VAR returns a VarAttr (name + type). Implementation handles '*' and id DIM.
   Note: curr_base_type is used at the base (ID DIM) to compute initial type,
   and '*' wraps/creates pointer types around the child's computed type. */
VAR:
    '*' VAR
    {
        /* insert pointer at the deepest/innermost base so arrays stay outermost */
        int newt = insertPointerAtBase($2->type);
        $2->type = newt;
        $$ = $2;
    }
    | ID DIM
    {
        int curtype = curr_base_type;
        /* apply dims right-to-left so e.g. ID[6][7] -> array(6, array(7, base)) */
        curtype = applyDims($2, curtype);
        $$ = newVarAttr($1, curtype);
        freeDimList($2);
    }
    ;

/* DIM: recursive list of [ num ] */
DIM:
      '[' NUM ']' DIM  { $$ = newDimNode($2, $4); }
    | /* empty */       { $$ = NULL; }
    ;

%%

/* C code section: implementations of helper functions */

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

/* ---- DimList helpers ---- */
struct DimList *newDimNode(int val, struct DimList *next) {
    struct DimList *n = (struct DimList*)malloc(sizeof(struct DimList));
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

/* ---- VarAttr helpers ---- */
struct VarAttr *newVarAttr(const char *name, int type) {
    struct VarAttr *v = (struct VarAttr*)malloc(sizeof(struct VarAttr));
    v->name = strdup(name);
    v->type = type;
    return v;
}
void freeVarAttr(struct VarAttr *v) {
    if (!v) return;
    if (v->name) free(v->name);
    free(v);
}

/* ---- Type table functions ---- */

void initTypeTable(void) {
    /* Pre-populate the 11 basic types in the order we'd like:
       0 VOID
       1 UCHR (unsigned char)
       2 CHR  (char)
       3 USRT (unsigned short)
       4 SRT  (short)
       5 ULNG (unsigned long)
       6 LNG  (long)
       7 UINT (unsigned int)
       8 INT  (int)
       9 FLT  (float)
       10 DBL (double)
    */
    TT_count = 0;

    addBasicType("void", 0); /* index 0 */
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

    /* curr_offset initial */
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

/* Linear search for existing array type */
int findType_array(int dim, int reftype) {
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == CAT_ARRAY && TT[i].dim == dim && TT[i].ref == reftype)
            return i;
    }
    return -1;
}

/* Linear search for existing pointer type */
int findType_pointer(int reftype) {
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == CAT_POINTER && TT[i].ref == reftype)
            return i;
    }
    return -1;
}

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
    /* width = dim * width of element type */
    long long w = (long long)dim * (long long)TT[reftype].width;
    TT[TT_count].width = (int)w;
    /* name = array(dim,element_descr) */
    {
        char inner[128];
        typeDescr_recursive(reftype, inner, sizeof(inner));
        snprintf(TT[TT_count].name, sizeof(TT[TT_count].name), "array(%d,%s)", dim, inner);
    }
    TT_count++;
    return TT_count - 1;
}

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
        char inner[128];
        typeDescr_recursive(reftype, inner, sizeof(inner));
        snprintf(TT[TT_count].name, sizeof(TT[TT_count].name), "pointer(%s)", inner);
    }
    TT_count++;
    return TT_count - 1;
}

/* ---- Symbol table functions ---- */
void addSymbolByName(const char *name, int typeidx) {
    if (ST_count >= MAX_SYMBOLS) {
        fprintf(stderr, "Symbol table overflow\n");
        exit(1);
    }
    if (lookupSymbol(name) != -1) {
        fprintf(stderr, "Error: duplicate symbol '%s' ignored\n", name);
        return;
    }
    /* start at current offset (which is always multiple of 4) */
    int start = curr_offset;
    int width = TT[typeidx].width;
    int end = start + width - 1;
    ST[ST_count].name = strdup(name);
    ST[ST_count].type = typeidx;
    ST[ST_count].start = start;
    ST[ST_count].end = end;
    ST_count++;
    /* next variable's start: round up end+1 to multiple of 4 */
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

/* Apply dimensions from right->left so that ID [d1][d2] becomes
   array(d1, array(d2, base)) which is the desired order. */
int applyDims(struct DimList *d, int base_type) {
    if (d == NULL) return base_type;
    /* recursively compute inner type from tail */
    int inner = applyDims(d->next, base_type);
    /* then apply this (current) dim as outer array */
    return addArrayType(d->val, inner);
}

int insertPointerAtBase(int typeidx) {
    if (typeidx < 0 || typeidx >= TT_count) {
        fprintf(stderr, "insertPointerAtBase: invalid type index %d\n", typeidx);
        return typeidx;
    }

    if (TT[typeidx].category == CAT_ARRAY) {
        /* recurse into element type */
        int new_ref = insertPointerAtBase(TT[typeidx].ref);
        /* create/find an array type with same dim but new_ref */
        return addArrayType(TT[typeidx].dim, new_ref);
    } else {
        /* basic or pointer: just add pointer on top */
        return addPointerType(typeidx);
    }
}

/* ---- Printing functions ---- */

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
        char descr[512];
        typeDescr_recursive(i, descr, sizeof(descr));
        printf("    Type %3d: %8d    %s\n", i, TT[i].width, descr);
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

/* ---- token_to_basic_index mapping ----
   We map token constants (VOID, UCHR, ...) to the pre-populated indices in TT.
*/
int token_to_basic_index(int tok) {
    switch (tok) {
        case VOID:  return 0;
        case UCHR:  return 1;
        case CHR:   return 2;
        case USRT:  return 3;
        case SRT:   return 4;
        case ULNG:  return 5;
        case LNG:   return 6;
        case UINT:  return 7;
        case INT:   return 8;
        case FLT:   return 9;
        case DBL:   return 10;
        default:    return -1;
    }
}

/* Helper to get basic index by token name in grammar actions:
   Here we just call token_to_basic_index with the token's enum constant.
*/
int getBasicIndexByToken(int tok) {
    return token_to_basic_index(tok);
}

/* ---- main ---- */

int main(int argc, char **argv) {
    if (argc > 1) {
        FILE *f = fopen(argv[1], "r");
        if (!f) {
            perror("fopen");
            return 1;
        }
        extern FILE *yyin;
        yyin = f;
    }
    initTypeTable();
    if (yyparse() == 0) {
        /* success */
        printTypeTable();
        printSymbolTable();
    } else {
        fprintf(stderr, "Parsing failed\n");
    }
    return 0;
}

/* End of file */
