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
    #define MAX_INSTRUCTIONS 10000

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
        int category;
        int type;
        union {
            long long ival;
            double fval;
            int tempnum;
            int offset;
        } value;
    };

    struct Boolean {
        int true_list[1000];
        int false_list[1000];
        int true_count;
        int false_count;
    };

    struct Statement {
        int next_list[1000];
        int next_count;
    };

    struct Marker {
        int instr;
    };

    // Three-address code storage
    char instructions[MAX_INSTRUCTIONS][256];
    int instr_count = 0;
    int leaders[MAX_INSTRUCTIONS];

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
    void printAddress(struct Address *addr);

    // Backpatching functions
    int emit(const char *instr);
    struct Boolean* makeBoolList(int i, int isTrue);
    struct Statement* makeStmtList(int i);
    void merge(int *list1, int *count1, int *list2, int count2);
    void backpatch(int *list, int count, int target);
    void printInstructions(void);

%}

%union{
    long long ival;
    char *sval;
    double fval;
    struct BaseInfo *bval;
    struct Address *aval;
    int tval;
    int rval;
    struct Boolean *boolval;
    struct Statement *stmtval;
    struct Marker *mval;
}

%token <sval> ID
%token <ival> NUM
%token <fval> FLTCNST
%token STRUCT LNG INT FLT DBL IF ELSE WHILE OR AND NOT
%token <rval> RELEQ RELNEQ RELLT RELLTE RELGT RELGTE

%type <bval> M1 M2 M3 M4 C1 C2
%type <ival> BASIC DIMS
%type <ival> N1 N2 N3 N4 W1 

%type <aval> EXPR TERM FACTOR ITEM SMPLITEM AREF
%type <tval> D1 D2

%type <boolval> BOOL
%type <stmtval> STMT STMTLIST ASGN N
%type <mval> M
%type <rval> RELOP

%left OR
%left AND
%right NOT

%start PROG

%%

PROG:  N1 DECLIST STMTLIST { 
            printf("\n+++ All declarations read\n"); 
            backpatch($3->next_list, $3->next_count, instr_count);
            emit("");  // Final empty instruction
            free($3);
        }
    ;

N1  :   {
            $$ = 0;
            printf("[N1] Set current_table to %lld \n", $$); 
        }
    ;

DECLIST:
        N2 DECL    
    |    DECLIST N3 DECL  
    ;

N2  :   {
            $$ = $<ival>0; 
            printf("[N2] Inherit current_table %lld\n", $$); 
        }
    ;

N3  :   {
            $$ = $<ival>-1; 
            printf("[N3] Pass current_table %lld\n", $$); 
        }
    ;

DECL:
        BASIC M1 VARLIST ';' 
        {
            printf("[DECL] Parsed BASIC declaration\n"); 
            freeBaseInfo($2);
        }
    |   STRUCT ID '{' N4 DECLIST W1 '}'  ';'   
        {
            printf("[DECL] Parsed new STRUCT definition '%s' (no vars)\n", $2); 
            free($2);
        }
    |   STRUCT ID '{' N4 DECLIST W1 '}' C1 VARLIST ';'   
        {
            printf("[DECL] Parsed new STRUCT definition '%s' (with vars)\n", $2); 
            freeBaseInfo($8);
            free($2);
        }
    |   STRUCT ID C2 VARLIST ';'   
        { 
            printf("[DECL] Parsed declaration using existing STRUCT '%s'\n", $2); 
            freeBaseInfo($3);
            free($2);
        }
    ;

N4  :   {
            $$ = NumTables++; 
            printf("[N4] Allocating new table #%lld for struct '%s'\n", $$, $<sval>-1); 
            int struct_type = addStructTypeWithTable($<sval>-1, $$);
            ST_count[$$] = 0;
            ST_width[$$] = 0;
        }
    ;

W1  :   {
            $$ = ST_width[$<ival>-1]; 
            printf("[W1] Captured pre-aligned width %lld from table %lld\n", $$, $<ival>-1); 
            $$ = align4($$);  
            printf("[W1] Final aligned width for struct '%s' is %lld\n", $<sval>-3, $$); 
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
            printf("[C1] Creating BaseInfo for new struct '%s' (type %d, table %d)\n",
                   struct_name, struct_type, $$->b_tablerow); 
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
            printf("[C2] Creating BaseInfo for existing struct '%s' (type %d, table %d)\n",
                   struct_name, struct_type, $$->b_tablerow); 
        }
    ;

BASIC:
     INT   { $$ = 0; printf("[BASIC] Found INT (type 0)\n"); }
    | LNG   { $$ = 1; printf("[BASIC] Found LONG (type 1)\n"); }
    | FLT   { $$ = 2; printf("[BASIC] Found FLOAT (type 2)\n"); }
    | DBL   { $$ = 3; printf("[BASIC] Found DOUBLE (type 3)\n"); }
    ;

VARLIST:
        VAR
    |   VARLIST ',' M2 VAR
    ;

M1  :   {
            $$ = makeBaseInfo($<ival>0); 
            $$->b_tablerow = $<ival>-1;
            printf("[M1] Creating BaseInfo for basic type %lld, table %lld\n", $<ival>0, $<ival>-1); 
        }
    ;

M2  :   {
            $$ = $<bval>-2; 
            printf("[M2] Passing BaseInfo for type %d through VARLIST\n", $$->b_type); 
        }
    ;

M3  :   {
            $$ = $<bval>-1; 
            printf("[M3] BaseInfo for ID '%s'. Base type %d, Table %d\n", $<sval>0, $$->b_type, $$->b_tablerow); 
        }
    ;

M4  :   {
            $$ = $<bval>-3;
            printf("[M4] Processing dimension. Base type for this array level is %d\n", $$->b_type); 
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
        printf("[VAR] Adding symbol '%s' with final type %d to table %d\n", $1, t, table_no); 
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
            printf("[DIMS] Creating array type. Dim: %lld, RefType: %d. New type: %lld\n", $2, reftype, $$); 
        }
    ;

STMTLIST:
        /* empty */
        {
            $$ = (struct Statement*)malloc(sizeof(struct Statement));
            $$->next_count = 0;
        }
    |   STMTLIST M STMT
        {
            backpatch($1->next_list, $1->next_count, $2->instr);
            $$ = $3;
            free($1);
            free($2);
        }
    ;

STMT: 
        ASGN 
        { 
            $$ = $1;
        }
    |   IF '(' BOOL ')' M '{' STMTLIST '}' 
        {
            backpatch($3->true_list, $3->true_count, $5->instr);
            $$ = (struct Statement*)malloc(sizeof(struct Statement));
            $$->next_count = 0;
            merge($$->next_list, &($$->next_count), $3->false_list, $3->false_count);
            merge($$->next_list, &($$->next_count), $7->next_list, $7->next_count);
            printf("[IF] Simple IF statement\n");
            free($3);
            free($5);
            free($7);
        }
    |   IF '(' BOOL ')' M '{' STMTLIST '}' N ELSE M '{' STMTLIST '}' 
        {
            backpatch($3->true_list, $3->true_count, $5->instr);
            backpatch($3->false_list, $3->false_count, $11->instr);
            $$ = (struct Statement*)malloc(sizeof(struct Statement));
            $$->next_count = 0;
            merge($$->next_list, &($$->next_count), $7->next_list, $7->next_count);
            merge($$->next_list, &($$->next_count), $9->next_list, $9->next_count);
            merge($$->next_list, &($$->next_count), $13->next_list, $13->next_count);
            printf("[IF-ELSE] IF-ELSE statement\n");
            free($3);
            free($5);
            free($7);
            free($9);
            free($11);
            free($13);
        }
    |   WHILE M '(' BOOL ')' M '{' STMTLIST '}' 
        {
            backpatch($8->next_list, $8->next_count, $2->instr);
            backpatch($4->true_list, $4->true_count, $6->instr);
            $$ = (struct Statement*)malloc(sizeof(struct Statement));
            $$->next_count = 0;
            merge($$->next_list, &($$->next_count), $4->false_list, $4->false_count);
            char buf[256];
            sprintf(buf, "      goto %d", $2->instr);
            emit(buf);
            printf("[WHILE] WHILE loop statement\n");
            free($2);
            free($4);
            free($6);
            free($8);
        }
    ;

M:  {
        $$ = (struct Marker*)malloc(sizeof(struct Marker));
        $$->instr = instr_count;
    }
    ;

N:  {
        $$ = (struct Statement*)malloc(sizeof(struct Statement));
        $$->next_count = 1;
        $$->next_list[0] = instr_count;
        emit("      goto "); 
    }
    ;

ASGN: 
    ITEM '=' EXPR ';'
    {
        printf("[ASGN] Assigning to lval (type %d) from rval (type %d)\n", $1->type, $3->type); 
        if (!isNumericType($1->type)) {
            fprintf(stderr, "*** Error: invalid type of l-value\n");
            freeAddress($1);
            freeAddress($3);
            YYABORT;
        }

        emitAssign($1, $3);
        freeAddress($1);
        freeAddress($3);
        
        $$ = (struct Statement*)malloc(sizeof(struct Statement));
        $$->next_count = 0;
    }
;

EXPR:
        EXPR '+' TERM 
        {
            printf("[EXPR] Binary op: +. Left (type %d), Right (type %d)\n", $1->type, $3->type); 
            $$ = emitBinaryOp($1, $3, '+');
            freeAddress($1);
            freeAddress($3);
        }
    |   EXPR '-' TERM
        {
            printf("[EXPR] Binary op: -. Left (type %d), Right (type %d)\n", $1->type, $3->type); 
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
            printf("[TERM] Binary op: *. Left (type %d), Right (type %d)\n", $1->type, $3->type); 
            $$ = emitBinaryOp($1, $3, '*');
            freeAddress($1);
            freeAddress($3);
        }
    |   TERM '/' FACTOR
        {
            printf("[TERM] Binary op: /. Left (type %d), Right (type %d)\n", $1->type, $3->type); 
            $$ = emitBinaryOp($1, $3, '/');
            freeAddress($1);
            freeAddress($3);
        }
    |   TERM '%' FACTOR
        {
            printf("[TERM] Binary op: %%. Left (type %d), Right (type %d)\n", $1->type, $3->type); 
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
            printf("[FACTOR] Found NUM: %lld (type int)\n", $1); 
            $$ = makeAddress(INTCONST, 0);
            $$->value.ival = $1;
        }
    |   FLTCNST
        {
            printf("[FACTOR] Found FLTCNST: %f (type double)\n", $1); 
            $$ = makeAddress(FLTCONST, 3);
            $$->value.fval = $1;
        }
    |   ITEM
        {
            $$ = $1;
        }
    |   '(' EXPR ')'
        {
            printf("[FACTOR] Found parenthesized EXPR\n"); 
            $$ = $2;
        }
    |   '-' FACTOR
    {
        printf("[FACTOR] Unary minus on type %d\n", $2->type);
        
        if ($2->category == INTCONST) {
            $2->value.ival = -($2->value.ival);
            $$ = $2;
        } else if ($2->category == FLTCONST) {
            $2->value.fval = -($2->value.fval);
            $$ = $2;
        } else {
            if (isNumericType($2->type)) {
                struct Address *zero;
                int base = getBaseType($2->type);
                if (base == 2 || base == 3) {
                    zero = makeAddress(FLTCONST, base);
                    zero->value.fval = 0.0;
                } else {
                    zero = makeAddress(INTCONST, base);
                    zero->value.ival = 0;
                }
                $$ = emitBinaryOp(zero, $2, '-');
                freeAddress(zero);
                freeAddress($2);
            } else {
                fprintf(stderr, "Error: Unary minus on non-numeric type\n");
                freeAddress($2);
                YYABORT;
            }
        }
    }
    ;

ITEM:
        D1 SMPLITEM
        {
            $$ = $2;
        }
    |   ITEM '.' D2 SMPLITEM
        {
            printf("[ITEM.DOT] Accessing struct member. Base type %d, Field type %d\n", $1->type, $4->type); 
            
            struct Address *base = $1;
            struct Address *field = $4;
            struct Address *result = makeAddress(TOFFSET, field->type);
            result->value.tempnum = temp_counter++;
            
            char buf[256];
            if (base->category == OFFSET) {
                if (field->category == OFFSET) {
                    sprintf(buf, "[int] t%d = %d + %d", result->value.tempnum, 
                           base->value.offset, field->value.offset);
                } else if (field->category == TOFFSET) {
                    sprintf(buf, "[int] t%d = %d + t%d", result->value.tempnum,
                           base->value.offset, field->value.tempnum);
                }
            } else if (base->category == TOFFSET) {
                if (field->category == OFFSET) {
                    sprintf(buf, "[int] t%d = t%d + %d", result->value.tempnum,
                           base->value.tempnum, field->value.offset);
                } else if (field->category == TOFFSET) {
                    sprintf(buf, "[int] t%d = t%d + t%d", result->value.tempnum,
                           base->value.tempnum, field->value.tempnum);
                }
            }
            emit(buf);
            
            freeAddress(base);
            freeAddress(field);
            $$ = result;
        }
    ;

D1:     {
            $$ = 0;
        }   
    ;

D2:
        /* empty */
        {
            struct Address *item = $<aval>-1;
            int item_type = item->type;
            
            if (TT[item_type].category != STRUCTURE) {
                fprintf(stderr, "Error: Dot operator used on non-structure type\n");
                YYABORT;
            }
            
            $$ = TT[item_type].reference;
            printf("[MARKER_ST] Found DOT. Base item is type %d (struct). Setting table to %d\n", item_type, $$); 
        }
    ;

SMPLITEM:
        ID
        {
            int table_no = 0;
            
            if ($<tval>0 > 0 && $<tval>0 < NumTables) {
                table_no = $<tval>0;
                printf("----Hello i set the table here %d\n", table_no); 
            }
            
            int sym_idx = lookupSymbol($1, table_no);
            if (sym_idx == -1) {
                fprintf(stderr, "Error: Undefined variable '%s' in table %d\n", $1, table_no);
                free($1);
                YYABORT;
            }
            
            $$ = makeAddress(OFFSET, ST_table[table_no][sym_idx].type);
            $$->value.offset = ST_table[table_no][sym_idx].offset;
            printf("[SMPLITEM] Found ID '%s' in table %d. Type: %d, Offset: %d\n", $1, table_no, $$->type, $$->value.offset); 
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
            
            printf("[AREF] Array access. Array type %d, Index type %d. Elem type %d\n", arr_type, idx->type, elem_type); 

            struct Address *idx_int = typecast(idx, 0);
            struct Address *idx_op = idx_int;
            if (idx_int->category != INTCONST && idx_int->category != FLTCONST) {
                idx_op = loadToTemp(idx_int);
            }
            
            struct Address *offset_calc = makeAddress(TOFFSET, 0);
            offset_calc->value.tempnum = temp_counter++;
            
            char buf[256];
            sprintf(buf, "[int] t%d = %d * ", offset_calc->value.tempnum, elem_width);
            char temp[64];
            if (idx_op->category == INTCONST) {
                sprintf(temp, "%lld", idx_op->value.ival);
            } else if (idx_op->category == TEMP) {
                sprintf(temp, "t%d", idx_op->value.tempnum);
            }
            strcat(buf, temp);
            emit(buf);
            
            struct Address *result = makeAddress(TOFFSET, elem_type);
            result->value.tempnum = temp_counter++;
            
            if (arr->category == OFFSET) {
                sprintf(buf, "[int] t%d = %d + t%d", result->value.tempnum,
                       arr->value.offset, offset_calc->value.tempnum);
            } else if (arr->category == TOFFSET) {
                sprintf(buf, "[int] t%d = t%d + t%d", result->value.tempnum,
                       arr->value.tempnum, offset_calc->value.tempnum);
            }
            emit(buf);
            
            freeAddress(arr);
            if (idx_op != idx_int) freeAddress(idx_op);
            freeAddress(idx_int);
            freeAddress(idx);
            freeAddress(offset_calc);
            
            $$ = result;
        }
    |   ID '[' EXPR ']'
        {
            int table_no = 0;
            
            if ($<tval>0 > 0 && $<tval>0 < NumTables) {
                int table2 = $<tval>0;
                table_no = $<tval>0;
                printf("----br br br Hello i set the table ID EXPR to %d\n", table2); 
            }
            
            int sym_idx = lookupSymbol($1, table_no);
            if (sym_idx == -1) {
                fprintf(stderr, "Error: in AREF Undefined variable '%s' in table %d\n", $1, table_no);
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
            
            printf("[AREF] ID array access: '%s' in table %d. Array type %d, Index type %d. Elem type %d\n", $1, table_no, arr_type, $3->type, elem_type); 

            struct Address *idx = $3;
            struct Address *idx_int = typecast(idx, 0);
            struct Address *idx_op = idx_int;
            if (idx_int->category != INTCONST && idx_int->category != FLTCONST) {
                idx_op = loadToTemp(idx_int);
            }
            
            struct Address *offset_calc = makeAddress(TOFFSET, 0);
            offset_calc->value.tempnum = temp_counter++;
            
            char buf[256];
            sprintf(buf, "[int] t%d = %d * ", offset_calc->value.tempnum, elem_width);
            char temp[64];
            if (idx_op->category == INTCONST) {
                sprintf(temp, "%lld", idx_op->value.ival);
            } else if (idx_op->category == TEMP) {
                sprintf(temp, "t%d", idx_op->value.tempnum);
            }
            strcat(buf, temp);
            emit(buf);
            
            struct Address *result = makeAddress(TOFFSET, elem_type);
            result->value.tempnum = temp_counter++;
            
            sprintf(buf, "[int] t%d = %d + t%d", result->value.tempnum,
                   base_offset, offset_calc->value.tempnum);
            emit(buf);
            
            if (idx_op != idx_int) freeAddress(idx_op);
            freeAddress(idx_int);
            freeAddress(idx);
            freeAddress(offset_calc);
            free($1);
            
            $$ = result;
        }
    ;

BOOL:
        BOOL OR M BOOL
        {
            backpatch($1->false_list, $1->false_count, $3->instr);
            $$ = (struct Boolean*)malloc(sizeof(struct Boolean));
            $$->true_count = 0;
            $$->false_count = 0;
            merge($$->true_list, &($$->true_count), $1->true_list, $1->true_count);
            merge($$->true_list, &($$->true_count), $4->true_list, $4->true_count);
            merge($$->false_list, &($$->false_count), $4->false_list, $4->false_count);
            printf("[BOOL] Boolean op: OR\n");
            free($1);
            free($3);
            free($4);
        }
    |   BOOL AND M BOOL
        {
            backpatch($1->true_list, $1->true_count, $3->instr);
            $$ = (struct Boolean*)malloc(sizeof(struct Boolean));
            $$->true_count = 0;
            $$->false_count = 0;
            merge($$->false_list, &($$->false_count), $1->false_list, $1->false_count);
            merge($$->false_list, &($$->false_count), $4->false_list, $4->false_count);
            merge($$->true_list, &($$->true_count), $4->true_list, $4->true_count);
            printf("[BOOL] Boolean op: AND\n");
            free($1);
            free($3);
            free($4);
        }
    |   NOT BOOL
        {
            $$ = (struct Boolean*)malloc(sizeof(struct Boolean));
            $$->true_count = $2->false_count;
            $$->false_count = $2->true_count;
            memcpy($$->true_list, $2->false_list, $2->false_count * sizeof(int));
            memcpy($$->false_list, $2->true_list, $2->true_count * sizeof(int));
            printf("[BOOL] Boolean op: NOT\n");
            free($2);
        }
    |   '(' BOOL ')'    
        {
            printf("[BOOL] Parenthesized BOOL\n");
            $$ = $2;
        }
    |   EXPR RELOP EXPR
        {
            printf("[BOOL] Relational op\n");
            
            struct Address *left_loaded = $1;
            if ($1->category != INTCONST && $1->category != FLTCONST) {
                left_loaded = loadToTemp($1);
            }
            
            struct Address *right_loaded = $3;
            if ($3->category != INTCONST && $3->category != FLTCONST) {
                right_loaded = loadToTemp($3);
            }

            int result_type = widenType(left_loaded->type, right_loaded->type);
            struct Address *left_op = typecast(left_loaded, result_type);
            struct Address *right_op = typecast(right_loaded, result_type);
            
            char buf[256];
            sprintf(buf, "      if ");
            char temp[128];
            
            // Print left operand
            if (left_op->category == INTCONST) {
                sprintf(temp, "%lld", left_op->value.ival);
            } else if (left_op->category == FLTCONST) {
                sprintf(temp, "%.16f", left_op->value.fval);
            } else if (left_op->category == TEMP) {
                sprintf(temp, "t%d", left_op->value.tempnum);
            }
            strcat(buf, temp);
            
            // Print operator
            switch($2) {
                case 1: strcat(buf, " == "); break;
                case 2: strcat(buf, " != "); break;
                case 3: strcat(buf, " < "); break;
                case 4: strcat(buf, " <= "); break;
                case 5: strcat(buf, " > "); break;
                case 6: strcat(buf, " >= "); break;
            }
            
            // Print right operand
            if (right_op->category == INTCONST) {
                sprintf(temp, "%lld", right_op->value.ival);
            } else if (right_op->category == FLTCONST) {
                sprintf(temp, "%.16f", right_op->value.fval);
            } else if (right_op->category == TEMP) {
                sprintf(temp, "t%d", right_op->value.tempnum);
            }
            strcat(buf, temp);
            strcat(buf, " goto ");
            
            $$ = (struct Boolean*)malloc(sizeof(struct Boolean));
            $$->true_count = 1;
            $$->true_list[0] = instr_count;
            $$->false_count = 1;
            $$->false_list[0] = instr_count + 1;
            
            emit(buf);
            int goto_instr = emit("      goto "); 
            leaders[goto_instr] = 1; 
            
            if (left_loaded != $1) freeAddress(left_loaded);
            if (right_loaded != $3) freeAddress(right_loaded);
            freeAddress(left_op);
            freeAddress(right_op);
            freeAddress($1);
            freeAddress($3);
        }
   ;

RELOP:
        RELEQ    { $$ = 1; printf("[RELOP] Found RELEQ (==)\n"); }
    |   RELNEQ   { $$ = 2; printf("[RELOP] Found RELNEQ (!=)\n"); }
    |   RELLT    { $$ = 3; printf("[RELOP] Found RELLT (<)\n"); }
    |   RELLTE   { $$ = 4; printf("[RELOP] Found RELLTE (<=)\n"); }
    |   RELGT    { $$ = 5; printf("[RELOP] Found RELGT (>)\n"); }
    |   RELGTE   { $$ = 6; printf("[RELOP] Found RELGTE (>=)\n"); }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

// Emit a three-address instruction
int emit(const char *instr) {
    if (instr_count >= MAX_INSTRUCTIONS) {
        fprintf(stderr, "Instruction array overflow\n");
        exit(1);
    }
    strncpy(instructions[instr_count], instr, 255);
    instructions[instr_count][255] = '\0';
    leaders[instr_count] = 0;
    return instr_count++;
}

// Backpatch a list of instructions with a target
void backpatch(int *list, int count, int target) {
    for (int i = 0; i < count; i++) {
        char buf[16];
        sprintf(buf, "%d", target);
        strcat(instructions[list[i]], buf);
        leaders[target] = 1;  // Mark target as a leader
    }
}

// Merge two lists
void merge(int *list1, int *count1, int *list2, int count2) {
    for (int i = 0; i < count2; i++) {
        list1[*count1] = list2[i];
        (*count1)++;
    }
}

// Print all instructions with blank lines between blocks
void printInstructions(void) {
    leaders[0] = 1;  
    
    for (int i = 0; i < instr_count; i++) {
        if (leaders[i] && i > 0) {
            printf("\n");  
        }
        printf("%5d : %s\n", i, instructions[i]);

    }
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
    
    char buf[256];
    sprintf(buf, "[%s] t%d = ", getTypeName(addr->type), temp->value.tempnum);
    
    if (addr->category == INTCONST) {
        char t[64];
        sprintf(t, "%lld", addr->value.ival);
        strcat(buf, t);
    } else if (addr->category == FLTCONST) {
        char t[64];
        sprintf(t, "%.16f", addr->value.fval);
        strcat(buf, t);
    } else if (addr->category == OFFSET) {
        char t[64];
        sprintf(t, "MEM(%d,%d)", addr->value.offset, TT[addr->type].width);
        strcat(buf, t);
    } else if (addr->category == TOFFSET) {
        char t[64];
        sprintf(t, "MEM(t%d,%d)", addr->value.tempnum, TT[addr->type].width);
        strcat(buf, t);
    }
    
    emit(buf);
    return temp;
}

struct Address* typecast(struct Address *addr, int target_type) {
    int src_type = addr->type;
    
    if (src_type == target_type) {
        return copyAddress(addr);
    }

    if (addr->category == INTCONST || addr->category == FLTCONST) {
        struct Address *result = makeAddress(TEMP, target_type);
        result->value.tempnum = temp_counter++;
        
        char buf[256];
        sprintf(buf, "[%s] t%d = (%s2%s)", 
               getTypeName(target_type), result->value.tempnum,
               getTypeName(src_type), getTypeName(target_type));
        
        char t[64];
        if (addr->category == INTCONST) {
            sprintf(t, "%lld", addr->value.ival);
        } else {
            sprintf(t, "%.16f", addr->value.fval);
        }
        strcat(buf, t);
        emit(buf);
        
        return result;
    }
    
    struct Address *temp_src = loadToTemp(addr);
    
    struct Address *result = makeAddress(TEMP, target_type);
    result->value.tempnum = temp_counter++;
    
    char buf[256];
    sprintf(buf, "[%s] t%d = (%s2%s)t%d", 
           getTypeName(target_type), result->value.tempnum,
           getTypeName(src_type), getTypeName(target_type),
           temp_src->value.tempnum);
    emit(buf);
    
    freeAddress(temp_src);
    return result;
}

int widenType(int type1, int type2) {
    int base1 = getBaseType(type1);
    int base2 = getBaseType(type2);
    
    if (base1 == 3 || base2 == 3) return 3;
    if (base1 == 1 && base2 == 2) return 3;
    if (base1 == 2 && base2 == 1) return 3;
    if (base1 == 1 || base2 == 1) return 1;
    if (base1 == 2 || base2 == 2) return 2;
    return 0;
}

void emitAssign(struct Address *lval, struct Address *rval) {
    if (lval->category != OFFSET && lval->category != TOFFSET) {
        fprintf(stderr, "Error: Invalid l-value in assignment\n");
        return;
    }
    
    struct Address *rval_converted = typecast(rval, lval->type);
    
    char buf[256];
    if (rval_converted->category == INTCONST || rval_converted->category == FLTCONST) {
        if (lval->category == OFFSET) {
            sprintf(buf, "[%s] MEM(%d,%d) = ", 
                   getTypeName(lval->type), lval->value.offset, 
                   TT[lval->type].width);
        } else {
            sprintf(buf, "[%s] MEM(t%d,%d) = ",
                   getTypeName(lval->type), lval->value.tempnum,
                   TT[lval->type].width);
        }
        
        char t[64];
        if (rval_converted->category == INTCONST) {
            sprintf(t, "%lld", rval_converted->value.ival);
        } else {
            sprintf(t, "%.16f", rval_converted->value.fval);
        }
        strcat(buf, t);
        emit(buf);
        
    } else {
        struct Address *rval_temp = loadToTemp(rval_converted);
        
        if (lval->category == OFFSET) {
            sprintf(buf, "[%s] MEM(%d,%d) = t%d", 
                   getTypeName(lval->type), lval->value.offset, 
                   TT[lval->type].width, rval_temp->value.tempnum);
        } else {
            sprintf(buf, "[%s] MEM(t%d,%d) = t%d",
                   getTypeName(lval->type), lval->value.tempnum,
                   TT[lval->type].width, rval_temp->value.tempnum);
        }
        emit(buf);
        
        if (rval_temp != rval_converted) freeAddress(rval_temp);
    }
    
    freeAddress(rval_converted);
}

struct Address* emitBinaryOp(struct Address *left, struct Address *right, char op) {
    int result_type = widenType(left->type, right->type);
    
    struct Address *left_cast = typecast(left, result_type);
    struct Address *left_op = left_cast;
    if (left_cast->category != INTCONST && left_cast->category != FLTCONST) {
        left_op = loadToTemp(left_cast);
    }
    
    struct Address *right_cast = typecast(right, result_type);
    struct Address *right_op = right_cast;
    if (right_cast->category != INTCONST && right_cast->category != FLTCONST) {
        right_op = loadToTemp(right_cast);
    }
    
    struct Address *result = makeAddress(TEMP, result_type);
    result->value.tempnum = temp_counter++;
    
    char buf[256];
    sprintf(buf, "[%s] t%d = ", getTypeName(result_type), result->value.tempnum);
    
    char t[64];
    if (left_op->category == INTCONST) {
        sprintf(t, "%lld", left_op->value.ival);
    } else if (left_op->category == FLTCONST) {
        sprintf(t, "%.16f", left_op->value.fval);
    } else {
        sprintf(t, "t%d", left_op->value.tempnum);
    }
    strcat(buf, t);
    
    sprintf(t, " %c ", op);
    strcat(buf, t);
    
    if (right_op->category == INTCONST) {
        sprintf(t, "%lld", right_op->value.ival);
    } else if (right_op->category == FLTCONST) {
        sprintf(t, "%.16f", right_op->value.fval);
    } else {
        sprintf(t, "t%d", right_op->value.tempnum);
    }
    strcat(buf, t);
    
    emit(buf);
    
    if (left_op != left_cast) freeAddress(left_op);
    if (right_op != right_cast) freeAddress(right_op);
    freeAddress(left_cast);
    freeAddress(right_cast);
    
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
    instr_count = 0;
    memset(leaders, 0, sizeof(leaders));

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

    printf("---[addSymbolByName] Added '%s' to table %d: type=%d, offset=%d, width=%d. New table width=%d\n",
           name, table_no, typeidx, offset, TT[typeidx].width, ST_width[table_no]); 
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
    int parse_result = yyparse();
    if (parse_result != 0) {
        fprintf(stderr, "Parsing failed\n");
    }
    printf("\n +++TYPE TABLE\n");
    printTypeTable();
    printSymbolTable();
    printInstructions();
    
    return parse_result;
}