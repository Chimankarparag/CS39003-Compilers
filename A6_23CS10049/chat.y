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

    typedef struct{
        char name[128];
        int category;
        int dimension;
        int reference;
        int width;
    } TypeTable;

    TypeTable TT[MAX_TYPES];
    int TT_count = 0;

    typedef struct{
        char name[128];
        int type;
        int offset;
    } SymbolTableEntry;

    SymbolTableEntry ST_table[MAX_TABLES][MAX_SYMBOLS_PER_TABLE];
    int ST_count[MAX_TABLES];
    int ST_width[MAX_TABLES];
    int NumTables = 1; /* table 0 is global */

    /* small stack to manage active table(s) while parsing nested structs;
       markers N1 and N2 will push/pop on this stack. This stack is
       manipulated only by grammar actions (N1/N2) below. */
    int table_stack[MAX_TABLES];
    int table_stack_top = -1; /* -1 means stack empty; when non-empty top holds active table */

    struct BaseInfo {
        int b_type;
        int b_width;
        int b_stars;
    };

    /* helpers */
    void initTypeTable(void);
    int addBasicType(const char *name, int width);
    int addArrayType(int dim, int reftype);
    int addPointerType(int reftype);
    int addStructTypeWithTable(const char *struct_name, int table_num);
    void setStructWidthInTT(int typeidx, int width);
    int lookupSymbolInTable(int tableno, const char *name);
    void addSymbolByNameInTable(int tableno, const char *name, int typeidx);
    int align4(int x);
    struct BaseInfo *makeBaseInfo(int baseidx);
    void freeBaseInfo(struct BaseInfo *b);
    void typeDescr_recursive(int idx, char *buf, int buflen);
    void printTypeTable(void);
    void printAllSymbolTables(void);
    void push_table(int t);
    int pop_table(void);
    int current_active_table(void);
    int findStructTypeIdxByTable(int tableno);

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

PROG: DECLIST   { printf("+++ All Declarations read\n\n"); }
    ;

DECLIST:
        DECL
    |   DECLIST DECL
    ;

DECL:
        BASIC M1 VARLIST ';' {
            freeBaseInfo($2);
        }
    /* struct definition only: create new table (N1), parse body (DECLIST), finish it (N2) */
    |   STRUCT ID '{' N1 DECLIST N2 '}' ';'
    /* struct definition followed by varlist (e.g. struct S { ... } a,b; ) */
    |   STRUCT ID '{' N1 DECLIST N2 '}' VARLIST ';'
    /* declaration using previously defined struct type: STRUCT ID VARLIST ; */
    |   STRUCT ID VARLIST ';'
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

// M1 inherits and basic
M1:
    {
        $$ = makeBaseInfo($<ival>0);
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

/* VAR inserts symbol into the current active table as maintained by N1/N2 markers */
VAR:
    STARS ID M3 DIMS
    {
        int i;
        int base = $<bval>0->b_type;
        int t = base;
        int target_table = current_active_table(); /* obtained from stack */

        for (i = 0; i < $1; ++i) t = addPointerType(t);

        if ($4 == -1) {
            addSymbolByNameInTable(target_table, $2, t);
        } else {
            addSymbolByNameInTable(target_table, $2, $4);
        }
        free($2);
    }
    ;

STARS:
        /* empty */ { $$ = 0; }
    | STARS '*'   { $$ = $1 + 1; }
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

/* --- Marker actions: N1 creates/ pushes a new table and returns its number; N2 finalizes struct width and pops --- */

/* N1: the mid-rule marker right after 'STRUCT ID {' — create a new symbol table for the struct, create TT entry */
N1:
    /* empty */ {
        /* create new symbol table for upcoming struct */
        if (NumTables >= MAX_TABLES) { fprintf(stderr,"Too many symbol tables\n"); exit(1); }
        int new_table = NumTables++;
        ST_count[new_table] = 0;
        ST_width[new_table] = 0;
        /* add struct type entry referencing this table (width 0 for now) */
        addStructTypeWithTable($-2 /* the STRUCT token's value is not used here */, new_table); 
        /* Note: $-2 doesn't give the ID string; we will instead get struct name from the grammar surrounding this marker.
           To obtain ID string here, we need this N1 to be placed after the ID and we must refer to $<sval>-1 or similar.
           In Yacc, within a mid-rule action, the previously-scaned symbols are addressed by negative indexes: $-1 is the last terminal.
           In our grammar, STRUCT ID '{' N1 ... — so here $-1 is '{', $-2 is ID's sval. So we use $-2 as the ID string. */
        /* Save new_table on stack */
        push_table(new_table);
        /* set the semantic value for N1 to the table number so calling context can use it if desired */
        $$ = new_table;
        /* Also update the TT entry's name to the struct name: find the TT entry we just created (it will be the last created) */
        /* However the helper addStructTypeWithTable used above doesn't know the struct name since we didn't pass it. Let's instead call a variant that receives the struct name. */
    }
    ;

/* N2: marker after finishing struct DECLIST; compute width, set TT width, and pop */
N2:
    /* empty */ {
        /* current active table is on top of stack */
        if (table_stack_top < 0) {
            fprintf(stderr, "Internal N2 error: table stack empty\n");
            $$ = -1;
        } else {
            int tbl = table_stack[table_stack_top];
            /* compute final width */
            int final_width = ST_width[tbl];
            final_width = align4(final_width);
            /* find corresponding TT entry (STRUCTURE that references this table) */
            int ttidx = findStructTypeIdxByTable(tbl);
            if (ttidx == -1) {
                fprintf(stderr, "Internal: couldn't find TT entry for table %d\n", tbl);
            } else {
                setStructWidthInTT(ttidx, final_width);
            }
            pop_table();
            $$ = tbl;
        }
    }
    ;

%%

/* ------------------ C helper code ------------------ */

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

struct BaseInfo *makeBaseInfo(int baseidx) {
    struct BaseInfo *b = (struct BaseInfo*)malloc(sizeof(struct BaseInfo));
    if (!b) { perror("malloc"); exit(1); }
    b->b_type = baseidx;
    b->b_width = (baseidx >=0 && baseidx < TT_count) ? TT[baseidx].width : 0;
    b->b_stars = 0;
    return b;
}
void freeBaseInfo(struct BaseInfo *b) {
    if (b) free(b);
}

void push_table(int t) {
    if (table_stack_top+1 >= MAX_TABLES) { fprintf(stderr,"Too many nested tables\n"); exit(1); }
    table_stack[++table_stack_top] = t;
}

int pop_table(void) {
    if (table_stack_top < 0) return -1;
    int t = table_stack[table_stack_top--];
    return t;
}

int current_active_table(void) {
    if (table_stack_top < 0) return 0; /* default to global table 0 */
    return table_stack[table_stack_top];
}

/* Type table and symbol table management */

void initTypeTable(void) {
    TT_count = 0;
    NumTables = 1;
    table_stack_top = -1;
    ST_count[0] = 0;
    ST_width[0] = 0;
    /* push main table as active so top-of-stack semantics work for top-level declarations */
    push_table(0);

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

/* Add pointer type */
int addPointerType(int reftype) {
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

/* Add array type */
int addArrayType(int dim, int reftype) {
    if (reftype >= 0 && reftype < TT_count && TT[reftype].category == STRUCTURE && TT[reftype].width == 0) {
        fprintf(stderr, "Error: array of incomplete struct type (struct %s) is not allowed until structure is fully defined\n", TT[reftype].name);
    }
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == ARR && TT[i].dimension == dim && TT[i].reference == reftype) {
            return i;
        }
    }
    if (TT_count >= MAX_TYPES) { fprintf(stderr,"Type table overflow\n"); exit(1); }
    TT[TT_count].category = ARR;
    TT[TT_count].dimension = dim;
    TT[TT_count].reference = reftype;
    long long w = 0;
    if (reftype >= 0 && reftype < TT_count) w = (long long)dim * (long long)TT[reftype].width;
    TT[TT_count].width = (int)w;
    char inner[256];
    typeDescr_recursive(reftype, inner, sizeof(inner));
    snprintf(TT[TT_count].name, sizeof(TT[TT_count].name), "array(%d,%s)", dim, inner);
    return TT_count++;
}

/* Add struct type and return its TT index; associates it with table_num.
   Name should be set by caller; here we provide a convenience wrapper which
   expects the struct name to be present in the grammar and passed explicitly. */
int addStructTypeWithTable(const char *struct_name, int table_num) {
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == STRUCTURE && strcmp(TT[i].name, struct_name) == 0) return i;
    }
    if (TT_count >= MAX_TYPES) { fprintf(stderr,"Type table overflow\n"); exit(1); }
    TT[TT_count].category = STRUCTURE;
    TT[TT_count].dimension = 0;
    TT[TT_count].reference = table_num;
    TT[TT_count].width = 0;
    strncpy(TT[TT_count].name, struct_name, sizeof(TT[TT_count].name)-1);
    TT[TT_count].name[sizeof(TT[TT_count].name)-1] = '\0';
    return TT_count++;
}

void setStructWidthInTT(int typeidx, int width) {
    if (typeidx < 0 || typeidx >= TT_count) return;
    TT[typeidx].width = width;
}

int lookupSymbolInTable(int tableno, const char *name) {
    if (tableno < 0 || tableno >= NumTables) return -1;
    for (int i = 0; i < ST_count[tableno]; ++i) {
        if (strcmp(ST_table[tableno][i].name, name) == 0) return i;
    }
    return -1;
}

/* Insert symbol into table and update running width */
void addSymbolByNameInTable(int tableno, const char *name, int typeidx) {
    if (tableno < 0 || tableno >= MAX_TABLES) {
        fprintf(stderr, "Internal error: invalid table number %d\n", tableno);
        return;
    }
    if (lookupSymbolInTable(tableno, name) != -1) {
        fprintf(stderr, "Error: Redeclaration of variable '%s' in symbol table %d\n", name, tableno);
        return;
    }
    if (ST_count[tableno] >= MAX_SYMBOLS_PER_TABLE) { fprintf(stderr,"Symbol table overflow in table %d\n", tableno); exit(1); }

    if (typeidx >= 0 && typeidx < TT_count && TT[typeidx].category == STRUCTURE && TT[typeidx].width == 0) {
        fprintf(stderr, "Error: using incomplete struct type '%s' for variable '%s' in table %d\n", TT[typeidx].name, name, tableno);
    }

    strncpy(ST_table[tableno][ST_count[tableno]].name, name, sizeof(ST_table[tableno][ST_count[tableno]].name)-1);
    ST_table[tableno][ST_count[tableno]].name[sizeof(ST_table[tableno][ST_count[tableno]].name)-1] = '\0';
    ST_table[tableno][ST_count[tableno]].type = typeidx;
    int size = 0;
    if (typeidx >= 0 && typeidx < TT_count) size = TT[typeidx].width;
    ST_table[tableno][ST_count[tableno]].offset = size;
    ST_count[tableno]++;
    ST_width[tableno] += align4(size);
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
        snprintf(buf, buflen, "struct %s (table %d)", TT[idx].name, TT[idx].reference);
    } else {
        snprintf(buf, buflen, "unknown");
    }
}

void printTypeTable(void) {
    printf("+++ %d types\n", TT_count);
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == STRUCTURE) {
            printf("    Type %3d: %8d    struct %s (table %d)\n", i, TT[i].width, TT[i].name, TT[i].reference);
        } else {
            printf("    Type %3d: %8d    %s\n", i, TT[i].width, TT[i].name);
        }
    }
    printf("\n");
}

int findStructTypeIdxByTable(int tableno) {
    for (int i = 0; i < TT_count; ++i) {
        if (TT[i].category == STRUCTURE && TT[i].reference == tableno) return i;
    }
    return -1;
}

void printAllSymbolTables(void) {
    for (int t = 0; t < NumTables; ++t) {
        if (t == 0) printf("+++ Symbol table %d [main]\n", t);
        else {
            int idx = findStructTypeIdxByTable(t);
            if (idx >= 0) printf("+++ Symbol table %d [struct %s]\n", t, TT[idx].name);
            else printf("+++ Symbol table %d [struct ?]\n", t);
        }
        int st_offset = 0;
        int end_offset = 0;
        for (int i = 0; i < ST_count[t]; ++i) {
            char descr[512];
            end_offset = st_offset + ST_table[t][i].offset - 1;
            typeDescr_recursive(ST_table[t][i].type, descr, sizeof(descr));
            printf("    %-18s %4d - %4d         type = %4d = %s\n",
                   ST_table[t][i].name, st_offset, end_offset , ST_table[t][i].type, descr);
            st_offset += align4(ST_table[t][i].offset);
        }
        printf("    Total width = %d\n\n", st_offset);
    }
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
        printAllSymbolTables();
    } else {
        fprintf(stderr, "Parsing failed\n");
    }
    return 0;
}
