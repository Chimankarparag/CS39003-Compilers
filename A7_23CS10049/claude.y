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

    // Address categories
    #define INTCONST 0
    #define FLTCONST 1
    #define TEMP 2
    #define OFFSET 3
    #define TOFFSET 4

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
        int b_tablerow;
    };

    // Address structure
    struct Address {
        int category;           // INTCONST, FLTCONST, TEMP, OFFSET, TOFFSET
        int type;              // index in TT
        union {
            long long ival;
            double fval;
            int tempnum;
            int offset;
        } value;
    };

    int temp_counter = 1;

    // Helper functions
    void initTypeTable(void);

    int addBasicType(const char *name, int width);
    int addArrayType(int dim, int reftype);
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

    // Three-address code functions
    struct Address* makeAddress(int cat, int type);
    void freeAddress(struct Address *a);
    struct Address* copyAddress(struct Address *a);

    const char* getTypeName(int typeidx);
    int getBaseType(int typeidx);
    int isNumericType(int typeidx);
    
    struct Address* loadToTemp(struct Address *addr);
    struct Address* typecast(struct Address *addr, int target_type);
    int widenType(int type1, int type2);

    void emitAssign(struct Address *lval, struct Address *rval);
    struct Address* emitBinaryOp(struct Address *left, struct Address *right, char op);
    struct Address* emitUnaryMinus(struct Address *operand);

    void printAddress(struct Address *addr);

%}

%union{
    long long ival;
    char *sval;
    double fval;
    struct BaseInfo *bval;
    struct Address *aval;
    int tval;  // for table numbers
}

%token <sval> ID
%token <ival> NUM
%token <fval> FLTCNST

%token STRUCT LNG INT FLT DBL DOT
%type <bval> M1 M2 M3 M4 C1 C2
%type <ival> BASIC DIMS
%type <ival> N1 N2 N3 N4 
%type <ival> W1 
%type <aval> EXPR TERM FACTOR ITEM SMPLITEM AREF
%type <tval> MARKER_ST

%start PROG

%%

PROG:  N1 DECLIST  STMTLIST { 
            printf("+++ All declarations read\n\n"); 
        }
    ;

N1  :   {
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

N2  :   {
            $$ = $<ival>0; 
        }
    ;

N3  :   {
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

N4  :   {
            $$ = NumTables++; 
            int struct_type = addStructTypeWithTable($<sval>-1, $$);
            ST_count[$$] = 0;
            ST_width[$$] = 0;
        }
    ;

W1  :   {
            $$ = ST_width[$<ival>-1]; 
            $$ = align4($$);  
            int struct_type = lookupStructType($<sval>-3);
            if (struct_type != -1)
                TT[struct_type].width = $$; 
        }
    ;

C1  :   {
            char *struct_name = $<sval>-5; 
            int struct_type = lookupStructType(struct_name);
            if (struct_type == -1) {
                fprintf(stderr, "Error: Undefined struct '%s'\n", struct_name);
                exit(1);
            }
            $$ = makeBaseInfo(struct_type);
            $$->b_type = struct_type;
            $$->b_tablerow = $<ival>-7;
            $$->b_width = TT[struct_type].width;
        }
    ; 

C2  :   {
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

M1  :   {
            $$ = makeBaseInfo($<ival>0); 
            $$->b_tablerow = $<ival>-1;
        }
    ;

M2  :   {
            $$ = $<bval>-2; 
        }
    ;

M3  :   {
            $$ = $<bval>-1; 
        }
    ;

M4  :   {
            $$ = $<bval>-3;
        }
    ;

VAR:
     ID M3 DIMS
    {
        struct BaseInfo *base_info = $2;
        int base = base_info->b_type;
        int table_no = base_info->b_tablerow;
        int t = base;

        if ($3 != -1) {
            t = $3;
        }
        addSymbolByName($1, t, table_no);
        free($1);
    }
    ;

DIMS:
        { $$ = -1; }
    |   '[' NUM ']' M4 DIMS
        {
            int reftype;
            if ($5 == -1) {
                struct BaseInfo *b = $4;
                reftype = b->b_type;
            } else {
                reftype = $5;
            }
            $$ = addArrayType($2, reftype);
        }
    ;

STMTLIST:
        /* empty */
    |   STMTLIST STMT
    ;

STMT: 
        ASGN
    ;

ASGN: 
        ITEM '=' EXPR ';'
        {
            // Check if ITEM is a valid l-value
            if (!isNumericType($1->type)) {
                fprintf(stderr, "*** Error: invalid type of l-value\n");
                freeAddress($1);
                freeAddress($3);
                YYABORT;
            }
            emitAssign($1, $3);
            freeAddress($1);
            freeAddress($3);
        }
    ;

EXPR:
        EXPR '+' TERM 
        {
            $$ = emitBinaryOp($1, $3, '+');
            freeAddress($1);
            freeAddress($3);
        }
    |   EXPR '-' TERM
        {
            $$ = emitBinaryOp($1, $3, '-');
            freeAddress($1);
            freeAddress($3);
        }
    |   TERM
        {
            $$ = $1;
        }
    ;

TERM: 
        TERM '*' FACTOR
        {
            $$ = emitBinaryOp($1, $3, '*');
            freeAddress($1);
            freeAddress($3);
        }
    |   TERM '/' FACTOR
        {
            $$ = emitBinaryOp($1, $3, '/');
            freeAddress($1);
            freeAddress($3);
        }
    |   TERM '%' FACTOR
        {
            $$ = emitBinaryOp($1, $3, '%');
            freeAddress($1);
            freeAddress($3);
        }
    |   FACTOR
        {
            $$ = $1;
        }
    ;

FACTOR:
        NUM
        {
            $$ = makeAddress(INTCONST, 0); // type 0 = int
            $$->value.ival = $1;
        }
    |   FLTCNST
        {
            $$ = makeAddress(FLTCONST, 3); // type 3 = double
            $$->value.fval = $1;
        }
    |   ITEM
        {
            $$ = $1;
        }
    |   '(' EXPR ')'
        {
            $$ = $2;
        }
    ;

ITEM:
        SMPLITEM
        {
            $$ = $1;
        }
    |   ITEM DOT MARKER_ST SMPLITEM
        {
            // $1 is the structure item
            // $3 is the symbol table number for the structure
            // $4 is the field within the structure
            
            struct Address *base = $1;
            struct Address *field = $4;
            
            // Add the field offset to the base offset
            struct Address *result = makeAddress(TOFFSET, field->type);
            result->value.tempnum = temp_counter++;
            
            // Emit offset calculation
            if (base->category == OFFSET) {
                if (field->category == OFFSET) {
                    printf("[int] t%d = %d + %d\n", result->value.tempnum, 
                           base->value.offset, field->value.offset);
                } else if (field->category == TOFFSET) {
                    printf("[int] t%d = %d + t%d\n", result->value.tempnum,
                           base->value.offset, field->value.tempnum);
                }
            } else if (base->category == TOFFSET) {
                if (field->category == OFFSET) {
                    printf("[int] t%d = t%d + %d\n", result->value.tempnum,
                           base->value.tempnum, field->value.offset);
                } else if (field->category == TOFFSET) {
                    printf("[int] t%d = t%d + t%d\n", result->value.tempnum,
                           base->value.tempnum, field->value.tempnum);
                }
            }
            
            freeAddress(base);
            freeAddress(field);
            $$ = result;
        }
    ;

MARKER_ST:
        /* empty */
        {
            // Get the type of ITEM on the left of DOT
            struct Address *item = $<aval>-1;
            int item_type = item->type;
            
            if (TT[item_type].category != STRUCTURE) {
                fprintf(stderr, "Error: Dot operator used on non-structure type\n");
                YYABORT;
            }
            
            // Set the symbol table number for SMPLITEM lookup
            $$ = TT[item_type].reference;
        }
    ;

SMPLITEM:
        ID
        {
            // Determine which symbol table to use
            int table_no = 0; // Default to global
            
            // Check if we're in a structure context (after DOT)
            // If MARKER_ST is on the stack at position -1, use it
            if ($<tval>-1 > 0 && $<tval>-1 < NumTables) {
                table_no = $<tval>-1;
            }
            
            int sym_idx = lookupSymbol($1, table_no);
            if (sym_idx == -1) {
                fprintf(stderr, "Error: Undefined variable '%s'\n", $1);
                free($1);
                YYABORT;
            }
            
            $$ = makeAddress(OFFSET, ST_table[table_no][sym_idx].type);
            $$->value.offset = ST_table[table_no][sym_idx].offset;
            free($1);
        }
    |   AREF
        {
            $$ = $1;
        }
    ;

AREF:
        AREF '[' EXPR ']'
        {
            struct Address *arr = $1;
            struct Address *idx = $3;
            
            int arr_type = arr->type;
            
            if (TT[arr_type].category != ARR) {
                fprintf(stderr, "Error: Subscript operator on non-array\n");
                freeAddress(arr);
                freeAddress(idx);
                YYABORT;
            }
            
            int elem_type = TT[arr_type].reference;
            int elem_width = TT[elem_type].width;
            
            // Load index to temp if needed
            struct Address *idx_temp = loadToTemp(idx);
            
            // Calculate offset
            struct Address *offset_calc = makeAddress(TOFFSET, 0); // type 0 = int for offset
            offset_calc->value.tempnum = temp_counter++;
            
            printf("[int] t%d = %d * ", offset_calc->value.tempnum, elem_width);
            printAddress(idx_temp);
            printf("\n");
            
            // Add to base
            struct Address *result = makeAddress(TOFFSET, elem_type);
            result->value.tempnum = temp_counter++;
            
            if (arr->category == OFFSET) {
                printf("[int] t%d = %d + t%d\n", result->value.tempnum,
                       arr->value.offset, offset_calc->value.tempnum);
            } else if (arr->category == TOFFSET) {
                printf("[int] t%d = t%d + t%d\n", result->value.tempnum,
                       arr->value.tempnum, offset_calc->value.tempnum);
            }
            
            freeAddress(arr);
            freeAddress(idx);
            freeAddress(idx_temp);
            freeAddress(offset_calc);
            
            $$ = result;
        }
    |   ID '[' EXPR ']'
        {
            // Determine which symbol table to use
            int table_no = 0; // Default to global
            
            // Check if we're in a structure context
            if ($<tval>-3 > 0 && $<tval>-3 < NumTables) {
                table_no = $<tval>-3;
            }
            
            int sym_idx = lookupSymbol($1, table_no);
            if (sym_idx == -1) {
                fprintf(stderr, "Error: Undefined variable '%s'\n", $1);
                free($1);
                freeAddress($3);
                YYABORT;
            }
            
            int arr_type = ST_table[table_no][sym_idx].type;
            
            if (TT[arr_type].category != ARR) {
                fprintf(stderr, "Error: Subscript operator on non-array\n");
                free($1);
                freeAddress($3);
                YYABORT;
            }
            
            int elem_type = TT[arr_type].reference;
            int elem_width = TT[elem_type].width;
            int base_offset = ST_table[table_no][sym_idx].offset;
            
            struct Address *idx = $3;
            struct Address *idx_temp = loadToTemp(idx);
            
            // Calculate offset
            struct Address *offset_calc = makeAddress(TOFFSET, 0); // type 0 = int
            offset_calc->value.tempnum = temp_counter++;
            
            printf("[int] t%d = %d * ", offset_calc->value.tempnum, elem_width);
            printAddress(idx_temp);
            printf("\n");
            
            // Add to base
            struct Address *result = makeAddress(TOFFSET, elem_type);
            result->value.tempnum = temp_counter++;
            
            printf("[int] t%d = %d + t%d\n", result->value.tempnum,
                   base_offset, offset_calc->value.tempnum);
            
            freeAddress(idx);
            freeAddress(idx_temp);
            freeAddress(offset_calc);
            free($1);
            
            $$ = result;
        }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

struct Address* makeAddress(int cat, int type) {
    struct Address *a = (struct Address*)malloc(sizeof(struct Address));
    if (!a) { perror("malloc"); exit(1); }
    a->category = cat;
    a->type = type;
    a->value.ival = 0;
    return a;
}

void freeAddress(struct Address *a) {
    if (a) free(a);
}

struct Address* copyAddress(struct Address *a) {
    struct Address *copy = makeAddress(a->category, a->type);
    copy->value = a->value;
    return copy;
}

struct BaseInfo *makeBaseInfo(int baseidx) {
    struct BaseInfo *b = (struct BaseInfo*)malloc(sizeof(struct BaseInfo));
    if (!b) { perror("malloc"); exit(1); }
    b->b_type = baseidx;
    b->b_width = (baseidx >= 0 && baseidx < TT_count) ? TT[baseidx].width : 0;
    b->b_tablerow = 0;
    return b;
}

void freeBaseInfo(struct BaseInfo *b) {
    if (b) free(b);
}

const char* getTypeName(int typeidx) {
    if (typeidx < 0 || typeidx >= TT_count) return "??";
    int base = getBaseType(typeidx);
    if (base == 0) return "int";
    if (base == 1) return "lng";
    if (base == 2) return "flt";
    if (base == 3) return "dbl";
    return "??";
}

int getBaseType(int typeidx) {
    if (typeidx < 0 || typeidx >= TT_count) return -1;
    if (TT[typeidx].category == BASE) return typeidx;
    if (TT[typeidx].category == ARR) return getBaseType(TT[typeidx].reference);
    if (TT[typeidx].category == PTR) return getBaseType(TT[typeidx].reference);
    return -1;
}

int isNumericType(int typeidx) {
    int base = getBaseType(typeidx);
    return (base >= 0 && base <= 3);
}

struct Address* loadToTemp(struct Address *addr) {
    if (addr->category == TEMP) {
        return copyAddress(addr);
    }
    
    struct Address *temp = makeAddress(TEMP, addr->type);
    temp->value.tempnum = temp_counter++;
    
    printf("[%s] t%d = ", getTypeName(addr->type), temp->value.tempnum);
    
    if (addr->category == INTCONST) {
        printf("%lld\n", addr->value.ival);
    } else if (addr->category == FLTCONST) {
        printf("%.16f\n", addr->value.fval);
    } else if (addr->category == OFFSET) {
        printf("MEM(%d,%d)\n", addr->value.offset, TT[addr->type].width);
    } else if (addr->category == TOFFSET) {
        printf("MEM(t%d,%d)\n", addr->value.tempnum, TT[addr->type].width);
    }
    
    return temp;
}

struct Address* typecast(struct Address *addr, int target_type) {
    int src_type = addr->type;
    
    if (src_type == target_type) {
        return copyAddress(addr);
    }
    
    struct Address *temp_src = loadToTemp(addr);
    
    struct Address *result = makeAddress(TEMP, target_type);
    result->value.tempnum = temp_counter++;
    
    printf("[%s] t%d = (%s2%s)t%d\n", 
           getTypeName(target_type), result->value.tempnum,
           getTypeName(src_type), getTypeName(target_type),
           temp_src->value.tempnum);
    
    freeAddress(temp_src);
    return result;
}

int widenType(int type1, int type2) {
    int base1 = getBaseType(type1);
    int base2 = getBaseType(type2);
    
    // double > float, long > int
    // Widening hierarchy: int -> long -> double
    //                      int -> float -> double
    
    if (base1 == 3 || base2 == 3) return 3; // double
    if (base1 == 1 && base2 == 2) return 3; // long * float = double
    if (base1 == 2 && base2 == 1) return 3; // float * long = double
    if (base1 == 1 || base2 == 1) return 1; // long
    if (base1 == 2 || base2 == 2) return 2; // float
    return 0; // int
}

void emitAssign(struct Address *lval, struct Address *rval) {
    // lval must be OFFSET or TOFFSET
    if (lval->category != OFFSET && lval->category != TOFFSET) {
        fprintf(stderr, "Error: Invalid l-value in assignment\n");
        return;
    }
    
    // Convert rval to lval's type if needed
    struct Address *rval_converted = typecast(rval, lval->type);
    struct Address *rval_temp = loadToTemp(rval_converted);
    
    // Emit store
    if (lval->category == OFFSET) {
        printf("[%s] MEM(%d,%d) = t%d\n", 
               getTypeName(lval->type), lval->value.offset, 
               TT[lval->type].width, rval_temp->value.tempnum);
    } else { // TOFFSET
        printf("[%s] MEM(t%d,%d) = t%d\n",
               getTypeName(lval->type), lval->value.tempnum,
               TT[lval->type].width, rval_temp->value.tempnum);
    }
    
    freeAddress(rval_converted);
    freeAddress(rval_temp);
}

struct Address* emitBinaryOp( struct Address *left, struct Address *right, char op) {
    int result_type = widenType(left->type, right->type);
    
    // Type cast operands if needed
    struct Address *left_cast = typecast(left, result_type);
    struct Address *right_cast = typecast(right, result_type);
    
    // Load to temps
    struct Address *left_temp = loadToTemp(left_cast);
    struct Address *right_temp = loadToTemp(right_cast);
    
    // Emit operation
    struct Address *result = makeAddress(TEMP, result_type);
    result->value.tempnum = temp_counter++;
    
    printf("[%s] t%d = t%d %c t%d\n",
           getTypeName(result_type), result->value.tempnum,
           left_temp->value.tempnum, op, right_temp->value.tempnum);
    
    freeAddress(left_cast);
    freeAddress(right_cast);
    freeAddress(left_temp);
    freeAddress(right_temp);
    
    return result;
}

void printAddress(struct Address *addr) {
    if (addr->category == INTCONST) {
        printf("%lld", addr->value.ival);
    } else if (addr->category == FLTCONST) {
        printf("%.16f", addr->value.fval);
    } else if (addr->category == TEMP) {
        printf("t%d", addr->value.tempnum);
    } else if (addr->category == OFFSET) {
        printf("%d", addr->value.offset);
    } else if (addr->category == TOFFSET) {
        printf("t%d", addr->value.tempnum);
    }
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