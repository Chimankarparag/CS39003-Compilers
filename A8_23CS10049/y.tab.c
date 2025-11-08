/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 1 "claude.y"

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


#line 201 "y.tab.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif

/* Use api.header.include to #include this header
   instead of duplicating it here.  */
#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    ID = 258,                      /* ID  */
    NUM = 259,                     /* NUM  */
    FLTCNST = 260,                 /* FLTCNST  */
    STRUCT = 261,                  /* STRUCT  */
    LNG = 262,                     /* LNG  */
    INT = 263,                     /* INT  */
    FLT = 264,                     /* FLT  */
    DBL = 265,                     /* DBL  */
    IF = 266,                      /* IF  */
    ELSE = 267,                    /* ELSE  */
    WHILE = 268,                   /* WHILE  */
    OR = 269,                      /* OR  */
    AND = 270,                     /* AND  */
    NOT = 271,                     /* NOT  */
    RELEQ = 272,                   /* RELEQ  */
    RELNEQ = 273,                  /* RELNEQ  */
    RELLT = 274,                   /* RELLT  */
    RELLTE = 275,                  /* RELLTE  */
    RELGT = 276,                   /* RELGT  */
    RELGTE = 277                   /* RELGTE  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif
/* Token kinds.  */
#define YYEMPTY -2
#define YYEOF 0
#define YYerror 256
#define YYUNDEF 257
#define ID 258
#define NUM 259
#define FLTCNST 260
#define STRUCT 261
#define LNG 262
#define INT 263
#define FLT 264
#define DBL 265
#define IF 266
#define ELSE 267
#define WHILE 268
#define OR 269
#define AND 270
#define NOT 271
#define RELEQ 272
#define RELNEQ 273
#define RELLT 274
#define RELLTE 275
#define RELGT 276
#define RELGTE 277

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 131 "claude.y"

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

#line 311 "y.tab.c"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);


#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_ID = 3,                         /* ID  */
  YYSYMBOL_NUM = 4,                        /* NUM  */
  YYSYMBOL_FLTCNST = 5,                    /* FLTCNST  */
  YYSYMBOL_STRUCT = 6,                     /* STRUCT  */
  YYSYMBOL_LNG = 7,                        /* LNG  */
  YYSYMBOL_INT = 8,                        /* INT  */
  YYSYMBOL_FLT = 9,                        /* FLT  */
  YYSYMBOL_DBL = 10,                       /* DBL  */
  YYSYMBOL_IF = 11,                        /* IF  */
  YYSYMBOL_ELSE = 12,                      /* ELSE  */
  YYSYMBOL_WHILE = 13,                     /* WHILE  */
  YYSYMBOL_OR = 14,                        /* OR  */
  YYSYMBOL_AND = 15,                       /* AND  */
  YYSYMBOL_NOT = 16,                       /* NOT  */
  YYSYMBOL_RELEQ = 17,                     /* RELEQ  */
  YYSYMBOL_RELNEQ = 18,                    /* RELNEQ  */
  YYSYMBOL_RELLT = 19,                     /* RELLT  */
  YYSYMBOL_RELLTE = 20,                    /* RELLTE  */
  YYSYMBOL_RELGT = 21,                     /* RELGT  */
  YYSYMBOL_RELGTE = 22,                    /* RELGTE  */
  YYSYMBOL_23_ = 23,                       /* ';'  */
  YYSYMBOL_24_ = 24,                       /* '{'  */
  YYSYMBOL_25_ = 25,                       /* '}'  */
  YYSYMBOL_26_ = 26,                       /* ','  */
  YYSYMBOL_27_ = 27,                       /* '['  */
  YYSYMBOL_28_ = 28,                       /* ']'  */
  YYSYMBOL_29_ = 29,                       /* '('  */
  YYSYMBOL_30_ = 30,                       /* ')'  */
  YYSYMBOL_31_ = 31,                       /* '='  */
  YYSYMBOL_32_ = 32,                       /* '+'  */
  YYSYMBOL_33_ = 33,                       /* '-'  */
  YYSYMBOL_34_ = 34,                       /* '*'  */
  YYSYMBOL_35_ = 35,                       /* '/'  */
  YYSYMBOL_36_ = 36,                       /* '%'  */
  YYSYMBOL_37_ = 37,                       /* '.'  */
  YYSYMBOL_YYACCEPT = 38,                  /* $accept  */
  YYSYMBOL_PROG = 39,                      /* PROG  */
  YYSYMBOL_N1 = 40,                        /* N1  */
  YYSYMBOL_DECLIST = 41,                   /* DECLIST  */
  YYSYMBOL_N2 = 42,                        /* N2  */
  YYSYMBOL_N3 = 43,                        /* N3  */
  YYSYMBOL_DECL = 44,                      /* DECL  */
  YYSYMBOL_N4 = 45,                        /* N4  */
  YYSYMBOL_W1 = 46,                        /* W1  */
  YYSYMBOL_C1 = 47,                        /* C1  */
  YYSYMBOL_C2 = 48,                        /* C2  */
  YYSYMBOL_BASIC = 49,                     /* BASIC  */
  YYSYMBOL_VARLIST = 50,                   /* VARLIST  */
  YYSYMBOL_M1 = 51,                        /* M1  */
  YYSYMBOL_M2 = 52,                        /* M2  */
  YYSYMBOL_M3 = 53,                        /* M3  */
  YYSYMBOL_M4 = 54,                        /* M4  */
  YYSYMBOL_VAR = 55,                       /* VAR  */
  YYSYMBOL_DIMS = 56,                      /* DIMS  */
  YYSYMBOL_STMTLIST = 57,                  /* STMTLIST  */
  YYSYMBOL_STMT = 58,                      /* STMT  */
  YYSYMBOL_M = 59,                         /* M  */
  YYSYMBOL_N = 60,                         /* N  */
  YYSYMBOL_ASGN = 61,                      /* ASGN  */
  YYSYMBOL_EXPR = 62,                      /* EXPR  */
  YYSYMBOL_TERM = 63,                      /* TERM  */
  YYSYMBOL_FACTOR = 64,                    /* FACTOR  */
  YYSYMBOL_ITEM = 65,                      /* ITEM  */
  YYSYMBOL_D1 = 66,                        /* D1  */
  YYSYMBOL_D2 = 67,                        /* D2  */
  YYSYMBOL_SMPLITEM = 68,                  /* SMPLITEM  */
  YYSYMBOL_AREF = 69,                      /* AREF  */
  YYSYMBOL_BOOL = 70,                      /* BOOL  */
  YYSYMBOL_RELOP = 71                      /* RELOP  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;




#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_int8 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if !defined yyoverflow

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* !defined yyoverflow */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  3
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   130

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  38
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  34
/* YYNRULES -- Number of rules.  */
#define YYNRULES  68
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  128

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   277


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,    36,     2,     2,
      29,    30,    34,    32,    26,    33,    37,    35,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,    23,
       2,    31,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    27,     2,    28,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    24,     2,    25,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   170,   170,   178,   185,   186,   189,   195,   202,   207,
     212,   218,   226,   235,   246,   262,   279,   280,   281,   282,
     286,   287,   290,   297,   303,   309,   316,   333,   334,   350,
     354,   364,   368,   380,   397,   415,   421,   430,   450,   457,
     464,   471,   478,   485,   492,   499,   505,   511,   515,   520,
     554,   558,   593,   600,   615,   636,   643,   702,   774,   788,
     802,   812,   817,   890,   891,   892,   893,   894,   895
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if YYDEBUG || 0
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "\"end of file\"", "error", "\"invalid token\"", "ID", "NUM", "FLTCNST",
  "STRUCT", "LNG", "INT", "FLT", "DBL", "IF", "ELSE", "WHILE", "OR", "AND",
  "NOT", "RELEQ", "RELNEQ", "RELLT", "RELLTE", "RELGT", "RELGTE", "';'",
  "'{'", "'}'", "','", "'['", "']'", "'('", "')'", "'='", "'+'", "'-'",
  "'*'", "'/'", "'%'", "'.'", "$accept", "PROG", "N1", "DECLIST", "N2",
  "N3", "DECL", "N4", "W1", "C1", "C2", "BASIC", "VARLIST", "M1", "M2",
  "M3", "M4", "VAR", "DIMS", "STMTLIST", "STMT", "M", "N", "ASGN", "EXPR",
  "TERM", "FACTOR", "ITEM", "D1", "D2", "SMPLITEM", "AREF", "BOOL",
  "RELOP", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-70)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-37)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int8 yypact[] =
{
     -70,    18,   -70,   -70,    63,    82,    82,    23,    38,   -70,
     -70,   -70,   -70,   -70,   -70,   -70,    91,    31,    90,    76,
     -70,   -70,   -70,     1,   103,   -70,    90,   -70,   -10,   -70,
      10,    78,    15,   -70,    40,   -70,    81,   -70,    19,    83,
     -70,   -70,   -70,   -70,    10,    10,    15,    51,    65,   -70,
      74,    -8,    10,    15,    -2,   103,    15,    15,    84,   -70,
     108,   -70,    90,   -70,    32,    -6,   -70,   -70,   -70,   -70,
     -70,   -70,   -70,    15,    15,    15,    15,    15,    15,   -70,
     -70,   -70,    -3,    64,   -70,   -70,    47,    53,    88,    86,
     -70,   -70,   -70,    65,    65,    45,   -70,   -70,   -70,    10,
      10,    92,   -70,   -70,   -70,    94,   -70,   100,   -70,   -70,
      95,   -70,    90,    83,    93,   -70,    72,   -70,   109,    97,
     -70,   111,   -70,   -70,    96,   -70,    99,   -70
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       3,     0,     6,     1,     7,     0,     0,    35,     0,    17,
      16,    18,    19,     4,    22,     5,    52,    15,     0,     0,
      35,    30,    31,     0,     0,    12,     0,    24,     0,    20,
      52,     0,    52,    53,    54,    50,    55,     6,     0,    27,
       8,    23,    45,    46,    52,    52,    52,     0,    40,    44,
      47,     0,    52,    52,     0,     0,    52,    52,     7,    11,
       0,    26,     0,    60,     0,     0,    49,    63,    64,    65,
      66,    67,    68,    52,    52,    52,    52,    52,    52,    35,
      35,    35,     0,     0,    37,    51,     0,     0,     0,     0,
      21,    48,    61,    38,    39,    62,    41,    42,    43,    52,
      52,     0,    35,    57,    56,    14,    25,    58,    59,    29,
       0,     9,     0,    27,    35,    29,     0,    28,    32,    35,
      10,     0,    34,    35,     0,    29,    35,    33
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -70,   -70,   -70,    89,   -70,   -70,   119,   -70,   -70,   -70,
     -70,   -70,   -25,   -70,   -70,   -70,   -70,    66,    14,   -69,
     -70,   -20,   -70,   -70,   -28,   -40,   -41,   113,   -70,   -70,
      75,   -70,   -42,   -70
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
       0,     1,     2,     4,     5,     6,    13,    37,    88,   112,
      26,    14,    28,    18,    62,    39,   113,    29,    61,     7,
      21,    16,   121,    22,    47,    48,    49,    50,    24,    55,
      35,    36,    51,    75
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int8 yytable[] =
{
      31,    38,    63,    65,    54,    66,    79,    80,    79,    80,
      82,    79,    80,    40,    42,    43,    41,    64,     3,    42,
      43,    84,    81,    -2,    92,    83,    44,   102,    86,    87,
      73,    74,    32,    93,    94,    96,    97,    98,    33,    45,
     114,    17,    59,    46,    53,    41,   119,    95,    46,    67,
      68,    69,    70,    71,    72,    25,   126,   107,   108,    99,
     100,   101,    91,   -29,    73,    74,   -29,    56,    67,    68,
      69,    70,    71,    72,   -29,   103,   -29,    73,    74,    73,
      74,   104,   110,    73,    74,    73,    74,   116,     8,     9,
      10,    11,    12,    27,    91,   120,    73,    74,    41,    76,
      77,    78,    19,   124,    20,    30,    34,    52,    57,   -13,
      60,    33,    89,   105,   106,    80,   109,   111,   118,   115,
     125,   -36,   122,   123,   127,    15,    58,   117,    90,    23,
      85
};

static const yytype_int8 yycheck[] =
{
      20,    26,    44,    45,    32,    46,    14,    15,    14,    15,
      52,    14,    15,    23,     4,     5,    26,    45,     0,     4,
       5,    23,    30,     0,    30,    53,    16,    30,    56,    57,
      32,    33,    31,    73,    74,    76,    77,    78,    37,    29,
     109,     3,    23,    33,    29,    26,   115,    75,    33,    17,
      18,    19,    20,    21,    22,    24,   125,    99,   100,    79,
      80,    81,    30,     0,    32,    33,     3,    27,    17,    18,
      19,    20,    21,    22,    11,    28,    13,    32,    33,    32,
      33,    28,   102,    32,    33,    32,    33,   112,     6,     7,
       8,     9,    10,     3,    30,    23,    32,    33,    26,    34,
      35,    36,    11,   123,    13,    29,     3,    29,    27,    25,
      27,    37,     4,    25,    28,    15,    24,    23,    25,    24,
      24,    12,    25,    12,    25,     6,    37,   113,    62,    16,
      55
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,    39,    40,     0,    41,    42,    43,    57,     6,     7,
       8,     9,    10,    44,    49,    44,    59,     3,    51,    11,
      13,    58,    61,    65,    66,    24,    48,     3,    50,    55,
      29,    59,    31,    37,     3,    68,    69,    45,    50,    53,
      23,    26,     4,     5,    16,    29,    33,    62,    63,    64,
      65,    70,    29,    29,    62,    67,    27,    27,    41,    23,
      27,    56,    52,    70,    62,    70,    64,    17,    18,    19,
      20,    21,    22,    32,    33,    71,    34,    35,    36,    14,
      15,    30,    70,    62,    23,    68,    62,    62,    46,     4,
      55,    30,    30,    63,    63,    62,    64,    64,    64,    59,
      59,    59,    30,    28,    28,    25,    28,    70,    70,    24,
      59,    23,    47,    54,    57,    24,    50,    56,    25,    57,
      23,    60,    25,    12,    59,    24,    57,    25
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr1[] =
{
       0,    38,    39,    40,    41,    41,    42,    43,    44,    44,
      44,    44,    45,    46,    47,    48,    49,    49,    49,    49,
      50,    50,    51,    52,    53,    54,    55,    56,    56,    57,
      57,    58,    58,    58,    58,    59,    60,    61,    62,    62,
      62,    63,    63,    63,    63,    64,    64,    64,    64,    64,
      65,    65,    66,    67,    68,    68,    69,    69,    70,    70,
      70,    70,    70,    71,    71,    71,    71,    71,    71
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     3,     0,     2,     3,     0,     0,     4,     8,
      10,     5,     0,     0,     0,     0,     1,     1,     1,     1,
       1,     4,     0,     0,     0,     0,     3,     0,     5,     0,
       3,     1,     8,    14,     9,     0,     0,     4,     3,     3,
       1,     3,     3,     3,     1,     1,     1,     1,     3,     2,
       2,     4,     0,     0,     1,     1,     4,     4,     4,     4,
       2,     3,     3,     1,     1,     1,     1,     1,     1
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)




# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp,
                 int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)]);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif






/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep)
{
  YY_USE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = YYEOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      goto yyerrlab1;
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 2: /* PROG: N1 DECLIST STMTLIST  */
#line 170 "claude.y"
                           { 
            printf("\n+++ All declarations read\n"); 
            backpatch((yyvsp[0].stmtval)->next_list, (yyvsp[0].stmtval)->next_count, instr_count);
            emit("");  // Final empty instruction
            free((yyvsp[0].stmtval));
        }
#line 1447 "y.tab.c"
    break;

  case 3: /* N1: %empty  */
#line 178 "claude.y"
        {
            (yyval.ival) = 0;
            printf("[N1] Set current_table to %lld \n", (yyval.ival)); 
        }
#line 1456 "y.tab.c"
    break;

  case 6: /* N2: %empty  */
#line 189 "claude.y"
        {
            (yyval.ival) = (yyvsp[0].ival); 
            printf("[N2] Inherit current_table %lld\n", (yyval.ival)); 
        }
#line 1465 "y.tab.c"
    break;

  case 7: /* N3: %empty  */
#line 195 "claude.y"
        {
            (yyval.ival) = (yyvsp[(-1) - (0)].ival); 
            printf("[N3] Pass current_table %lld\n", (yyval.ival)); 
        }
#line 1474 "y.tab.c"
    break;

  case 8: /* DECL: BASIC M1 VARLIST ';'  */
#line 203 "claude.y"
        {
            printf("[DECL] Parsed BASIC declaration\n"); 
            freeBaseInfo((yyvsp[-2].bval));
        }
#line 1483 "y.tab.c"
    break;

  case 9: /* DECL: STRUCT ID '{' N4 DECLIST W1 '}' ';'  */
#line 208 "claude.y"
        {
            printf("[DECL] Parsed new STRUCT definition '%s' (no vars)\n", (yyvsp[-6].sval)); 
            free((yyvsp[-6].sval));
        }
#line 1492 "y.tab.c"
    break;

  case 10: /* DECL: STRUCT ID '{' N4 DECLIST W1 '}' C1 VARLIST ';'  */
#line 213 "claude.y"
        {
            printf("[DECL] Parsed new STRUCT definition '%s' (with vars)\n", (yyvsp[-8].sval)); 
            freeBaseInfo((yyvsp[-2].bval));
            free((yyvsp[-8].sval));
        }
#line 1502 "y.tab.c"
    break;

  case 11: /* DECL: STRUCT ID C2 VARLIST ';'  */
#line 219 "claude.y"
        { 
            printf("[DECL] Parsed declaration using existing STRUCT '%s'\n", (yyvsp[-3].sval)); 
            freeBaseInfo((yyvsp[-2].bval));
            free((yyvsp[-3].sval));
        }
#line 1512 "y.tab.c"
    break;

  case 12: /* N4: %empty  */
#line 226 "claude.y"
        {
            (yyval.ival) = NumTables++; 
            printf("[N4] Allocating new table #%lld for struct '%s'\n", (yyval.ival), (yyvsp[(-1) - (0)].sval)); 
            int struct_type = addStructTypeWithTable((yyvsp[(-1) - (0)].sval), (yyval.ival));
            ST_count[(yyval.ival)] = 0;
            ST_width[(yyval.ival)] = 0;
        }
#line 1524 "y.tab.c"
    break;

  case 13: /* W1: %empty  */
#line 235 "claude.y"
        {
            (yyval.ival) = ST_width[(yyvsp[(-1) - (0)].ival)]; 
            printf("[W1] Captured pre-aligned width %lld from table %lld\n", (yyval.ival), (yyvsp[(-1) - (0)].ival)); 
            (yyval.ival) = align4((yyval.ival));  
            printf("[W1] Final aligned width for struct '%s' is %lld\n", (yyvsp[(-3) - (0)].sval), (yyval.ival)); 
            int struct_type = lookupStructType((yyvsp[(-3) - (0)].sval));
            if (struct_type != -1)
                TT[struct_type].width = (yyval.ival); 
        }
#line 1538 "y.tab.c"
    break;

  case 14: /* C1: %empty  */
#line 246 "claude.y"
        {
            char *struct_name = (yyvsp[(-5) - (0)].sval); 
            int struct_type = lookupStructType(struct_name);
            if (struct_type == -1) {
                fprintf(stderr, "Error: Undefined struct '%s'\n", struct_name);
                exit(1);
            }
            (yyval.bval) = makeBaseInfo(struct_type);
            (yyval.bval)->b_type = struct_type;
            (yyval.bval)->b_tablerow = (yyvsp[(-7) - (0)].ival);
            (yyval.bval)->b_width = TT[struct_type].width;
            printf("[C1] Creating BaseInfo for new struct '%s' (type %d, table %d)\n",
                   struct_name, struct_type, (yyval.bval)->b_tablerow); 
        }
#line 1557 "y.tab.c"
    break;

  case 15: /* C2: %empty  */
#line 262 "claude.y"
        {
            char *struct_name = (yyvsp[0].sval);  
            int struct_type = lookupStructType(struct_name);
            if (struct_type == -1) {
                fprintf(stderr, "Error: Undefined struct '%s'\n", struct_name);
                exit(1);
            }
            (yyval.bval) = makeBaseInfo(struct_type);
            (yyval.bval)->b_type = struct_type;
            (yyval.bval)->b_tablerow = (yyvsp[(-2) - (0)].ival);
            (yyval.bval)->b_width = TT[struct_type].width;
            printf("[C2] Creating BaseInfo for existing struct '%s' (type %d, table %d)\n",
                   struct_name, struct_type, (yyval.bval)->b_tablerow); 
        }
#line 1576 "y.tab.c"
    break;

  case 16: /* BASIC: INT  */
#line 279 "claude.y"
           { (yyval.ival) = 0; printf("[BASIC] Found INT (type 0)\n"); }
#line 1582 "y.tab.c"
    break;

  case 17: /* BASIC: LNG  */
#line 280 "claude.y"
            { (yyval.ival) = 1; printf("[BASIC] Found LONG (type 1)\n"); }
#line 1588 "y.tab.c"
    break;

  case 18: /* BASIC: FLT  */
#line 281 "claude.y"
            { (yyval.ival) = 2; printf("[BASIC] Found FLOAT (type 2)\n"); }
#line 1594 "y.tab.c"
    break;

  case 19: /* BASIC: DBL  */
#line 282 "claude.y"
            { (yyval.ival) = 3; printf("[BASIC] Found DOUBLE (type 3)\n"); }
#line 1600 "y.tab.c"
    break;

  case 22: /* M1: %empty  */
#line 290 "claude.y"
        {
            (yyval.bval) = makeBaseInfo((yyvsp[0].ival)); 
            (yyval.bval)->b_tablerow = (yyvsp[(-1) - (0)].ival);
            printf("[M1] Creating BaseInfo for basic type %lld, table %lld\n", (yyvsp[0].ival), (yyvsp[(-1) - (0)].ival)); 
        }
#line 1610 "y.tab.c"
    break;

  case 23: /* M2: %empty  */
#line 297 "claude.y"
        {
            (yyval.bval) = (yyvsp[(-2) - (0)].bval); 
            printf("[M2] Passing BaseInfo for type %d through VARLIST\n", (yyval.bval)->b_type); 
        }
#line 1619 "y.tab.c"
    break;

  case 24: /* M3: %empty  */
#line 303 "claude.y"
        {
            (yyval.bval) = (yyvsp[(-1) - (0)].bval); 
            printf("[M3] BaseInfo for ID '%s'. Base type %d, Table %d\n", (yyvsp[0].sval), (yyval.bval)->b_type, (yyval.bval)->b_tablerow); 
        }
#line 1628 "y.tab.c"
    break;

  case 25: /* M4: %empty  */
#line 309 "claude.y"
        {
            (yyval.bval) = (yyvsp[(-3) - (0)].bval);
            printf("[M4] Processing dimension. Base type for this array level is %d\n", (yyval.bval)->b_type); 
        }
#line 1637 "y.tab.c"
    break;

  case 26: /* VAR: ID M3 DIMS  */
#line 317 "claude.y"
    {
        struct BaseInfo *base_info = (yyvsp[-1].bval);
        int base = base_info->b_type;
        int table_no = base_info->b_tablerow;
        int t = base;

        if ((yyvsp[0].ival) != -1) {
            t = (yyvsp[0].ival);
        }
        printf("[VAR] Adding symbol '%s' with final type %d to table %d\n", (yyvsp[-2].sval), t, table_no); 
        addSymbolByName((yyvsp[-2].sval), t, table_no);
        free((yyvsp[-2].sval));
    }
#line 1655 "y.tab.c"
    break;

  case 27: /* DIMS: %empty  */
#line 333 "claude.y"
        { (yyval.ival) = -1; }
#line 1661 "y.tab.c"
    break;

  case 28: /* DIMS: '[' NUM ']' M4 DIMS  */
#line 335 "claude.y"
        {
            int reftype;
            if ((yyvsp[0].ival) == -1) {
                struct BaseInfo *b = (yyvsp[-1].bval);
                reftype = b->b_type;
            } else {
                reftype = (yyvsp[0].ival);
            }
            (yyval.ival) = addArrayType((yyvsp[-3].ival), reftype);
            printf("[DIMS] Creating array type. Dim: %lld, RefType: %d. New type: %lld\n", (yyvsp[-3].ival), reftype, (yyval.ival)); 
        }
#line 1677 "y.tab.c"
    break;

  case 29: /* STMTLIST: %empty  */
#line 350 "claude.y"
        {
            (yyval.stmtval) = (struct Statement*)malloc(sizeof(struct Statement));
            (yyval.stmtval)->next_count = 0;
        }
#line 1686 "y.tab.c"
    break;

  case 30: /* STMTLIST: STMTLIST M STMT  */
#line 355 "claude.y"
        {
            backpatch((yyvsp[-2].stmtval)->next_list, (yyvsp[-2].stmtval)->next_count, (yyvsp[-1].mval)->instr);
            (yyval.stmtval) = (yyvsp[0].stmtval);
            free((yyvsp[-2].stmtval));
            free((yyvsp[-1].mval));
        }
#line 1697 "y.tab.c"
    break;

  case 31: /* STMT: ASGN  */
#line 365 "claude.y"
        { 
            (yyval.stmtval) = (yyvsp[0].stmtval);
        }
#line 1705 "y.tab.c"
    break;

  case 32: /* STMT: IF '(' BOOL ')' M '{' STMTLIST '}'  */
#line 369 "claude.y"
        {
            backpatch((yyvsp[-5].boolval)->true_list, (yyvsp[-5].boolval)->true_count, (yyvsp[-3].mval)->instr);
            (yyval.stmtval) = (struct Statement*)malloc(sizeof(struct Statement));
            (yyval.stmtval)->next_count = 0;
            merge((yyval.stmtval)->next_list, &((yyval.stmtval)->next_count), (yyvsp[-5].boolval)->false_list, (yyvsp[-5].boolval)->false_count);
            merge((yyval.stmtval)->next_list, &((yyval.stmtval)->next_count), (yyvsp[-1].stmtval)->next_list, (yyvsp[-1].stmtval)->next_count);
            printf("[IF] Simple IF statement\n");
            free((yyvsp[-5].boolval));
            free((yyvsp[-3].mval));
            free((yyvsp[-1].stmtval));
        }
#line 1721 "y.tab.c"
    break;

  case 33: /* STMT: IF '(' BOOL ')' M '{' STMTLIST '}' N ELSE M '{' STMTLIST '}'  */
#line 381 "claude.y"
        {
            backpatch((yyvsp[-11].boolval)->true_list, (yyvsp[-11].boolval)->true_count, (yyvsp[-9].mval)->instr);
            backpatch((yyvsp[-11].boolval)->false_list, (yyvsp[-11].boolval)->false_count, (yyvsp[-3].mval)->instr);
            (yyval.stmtval) = (struct Statement*)malloc(sizeof(struct Statement));
            (yyval.stmtval)->next_count = 0;
            merge((yyval.stmtval)->next_list, &((yyval.stmtval)->next_count), (yyvsp[-7].stmtval)->next_list, (yyvsp[-7].stmtval)->next_count);
            merge((yyval.stmtval)->next_list, &((yyval.stmtval)->next_count), (yyvsp[-5].stmtval)->next_list, (yyvsp[-5].stmtval)->next_count);
            merge((yyval.stmtval)->next_list, &((yyval.stmtval)->next_count), (yyvsp[-1].stmtval)->next_list, (yyvsp[-1].stmtval)->next_count);
            printf("[IF-ELSE] IF-ELSE statement\n");
            free((yyvsp[-11].boolval));
            free((yyvsp[-9].mval));
            free((yyvsp[-7].stmtval));
            free((yyvsp[-5].stmtval));
            free((yyvsp[-3].mval));
            free((yyvsp[-1].stmtval));
        }
#line 1742 "y.tab.c"
    break;

  case 34: /* STMT: WHILE M '(' BOOL ')' M '{' STMTLIST '}'  */
#line 398 "claude.y"
        {
            backpatch((yyvsp[-1].stmtval)->next_list, (yyvsp[-1].stmtval)->next_count, (yyvsp[-7].mval)->instr);
            backpatch((yyvsp[-5].boolval)->true_list, (yyvsp[-5].boolval)->true_count, (yyvsp[-3].mval)->instr);
            (yyval.stmtval) = (struct Statement*)malloc(sizeof(struct Statement));
            (yyval.stmtval)->next_count = 0;
            merge((yyval.stmtval)->next_list, &((yyval.stmtval)->next_count), (yyvsp[-5].boolval)->false_list, (yyvsp[-5].boolval)->false_count);
            char buf[256];
            sprintf(buf, "      goto %d", (yyvsp[-7].mval)->instr);
            emit(buf);
            printf("[WHILE] WHILE loop statement\n");
            free((yyvsp[-7].mval));
            free((yyvsp[-5].boolval));
            free((yyvsp[-3].mval));
            free((yyvsp[-1].stmtval));
        }
#line 1762 "y.tab.c"
    break;

  case 35: /* M: %empty  */
#line 415 "claude.y"
    {
        (yyval.mval) = (struct Marker*)malloc(sizeof(struct Marker));
        (yyval.mval)->instr = instr_count;
    }
#line 1771 "y.tab.c"
    break;

  case 36: /* N: %empty  */
#line 421 "claude.y"
    {
        (yyval.stmtval) = (struct Statement*)malloc(sizeof(struct Statement));
        (yyval.stmtval)->next_count = 1;
        (yyval.stmtval)->next_list[0] = instr_count;
        emit("      goto "); 
    }
#line 1782 "y.tab.c"
    break;

  case 37: /* ASGN: ITEM '=' EXPR ';'  */
#line 431 "claude.y"
    {
        printf("[ASGN] Assigning to lval (type %d) from rval (type %d)\n", (yyvsp[-3].aval)->type, (yyvsp[-1].aval)->type); 
        if (!isNumericType((yyvsp[-3].aval)->type)) {
            fprintf(stderr, "*** Error: invalid type of l-value\n");
            freeAddress((yyvsp[-3].aval));
            freeAddress((yyvsp[-1].aval));
            YYABORT;
        }

        emitAssign((yyvsp[-3].aval), (yyvsp[-1].aval));
        freeAddress((yyvsp[-3].aval));
        freeAddress((yyvsp[-1].aval));
        
        (yyval.stmtval) = (struct Statement*)malloc(sizeof(struct Statement));
        (yyval.stmtval)->next_count = 0;
    }
#line 1803 "y.tab.c"
    break;

  case 38: /* EXPR: EXPR '+' TERM  */
#line 451 "claude.y"
        {
            printf("[EXPR] Binary op: +. Left (type %d), Right (type %d)\n", (yyvsp[-2].aval)->type, (yyvsp[0].aval)->type); 
            (yyval.aval) = emitBinaryOp((yyvsp[-2].aval), (yyvsp[0].aval), '+');
            freeAddress((yyvsp[-2].aval));
            freeAddress((yyvsp[0].aval));
        }
#line 1814 "y.tab.c"
    break;

  case 39: /* EXPR: EXPR '-' TERM  */
#line 458 "claude.y"
        {
            printf("[EXPR] Binary op: -. Left (type %d), Right (type %d)\n", (yyvsp[-2].aval)->type, (yyvsp[0].aval)->type); 
            (yyval.aval) = emitBinaryOp((yyvsp[-2].aval), (yyvsp[0].aval), '-');
            freeAddress((yyvsp[-2].aval));
            freeAddress((yyvsp[0].aval));
        }
#line 1825 "y.tab.c"
    break;

  case 40: /* EXPR: TERM  */
#line 465 "claude.y"
        {
            (yyval.aval) = (yyvsp[0].aval);
        }
#line 1833 "y.tab.c"
    break;

  case 41: /* TERM: TERM '*' FACTOR  */
#line 472 "claude.y"
        {
            printf("[TERM] Binary op: *. Left (type %d), Right (type %d)\n", (yyvsp[-2].aval)->type, (yyvsp[0].aval)->type); 
            (yyval.aval) = emitBinaryOp((yyvsp[-2].aval), (yyvsp[0].aval), '*');
            freeAddress((yyvsp[-2].aval));
            freeAddress((yyvsp[0].aval));
        }
#line 1844 "y.tab.c"
    break;

  case 42: /* TERM: TERM '/' FACTOR  */
#line 479 "claude.y"
        {
            printf("[TERM] Binary op: /. Left (type %d), Right (type %d)\n", (yyvsp[-2].aval)->type, (yyvsp[0].aval)->type); 
            (yyval.aval) = emitBinaryOp((yyvsp[-2].aval), (yyvsp[0].aval), '/');
            freeAddress((yyvsp[-2].aval));
            freeAddress((yyvsp[0].aval));
        }
#line 1855 "y.tab.c"
    break;

  case 43: /* TERM: TERM '%' FACTOR  */
#line 486 "claude.y"
        {
            printf("[TERM] Binary op: %%. Left (type %d), Right (type %d)\n", (yyvsp[-2].aval)->type, (yyvsp[0].aval)->type); 
            (yyval.aval) = emitBinaryOp((yyvsp[-2].aval), (yyvsp[0].aval), '%');
            freeAddress((yyvsp[-2].aval));
            freeAddress((yyvsp[0].aval));
        }
#line 1866 "y.tab.c"
    break;

  case 44: /* TERM: FACTOR  */
#line 493 "claude.y"
        {
            (yyval.aval) = (yyvsp[0].aval);
        }
#line 1874 "y.tab.c"
    break;

  case 45: /* FACTOR: NUM  */
#line 500 "claude.y"
        {
            printf("[FACTOR] Found NUM: %lld (type int)\n", (yyvsp[0].ival)); 
            (yyval.aval) = makeAddress(INTCONST, 0);
            (yyval.aval)->value.ival = (yyvsp[0].ival);
        }
#line 1884 "y.tab.c"
    break;

  case 46: /* FACTOR: FLTCNST  */
#line 506 "claude.y"
        {
            printf("[FACTOR] Found FLTCNST: %f (type double)\n", (yyvsp[0].fval)); 
            (yyval.aval) = makeAddress(FLTCONST, 3);
            (yyval.aval)->value.fval = (yyvsp[0].fval);
        }
#line 1894 "y.tab.c"
    break;

  case 47: /* FACTOR: ITEM  */
#line 512 "claude.y"
        {
            (yyval.aval) = (yyvsp[0].aval);
        }
#line 1902 "y.tab.c"
    break;

  case 48: /* FACTOR: '(' EXPR ')'  */
#line 516 "claude.y"
        {
            printf("[FACTOR] Found parenthesized EXPR\n"); 
            (yyval.aval) = (yyvsp[-1].aval);
        }
#line 1911 "y.tab.c"
    break;

  case 49: /* FACTOR: '-' FACTOR  */
#line 521 "claude.y"
    {
        printf("[FACTOR] Unary minus on type %d\n", (yyvsp[0].aval)->type);
        
        if ((yyvsp[0].aval)->category == INTCONST) {
            (yyvsp[0].aval)->value.ival = -((yyvsp[0].aval)->value.ival);
            (yyval.aval) = (yyvsp[0].aval);
        } else if ((yyvsp[0].aval)->category == FLTCONST) {
            (yyvsp[0].aval)->value.fval = -((yyvsp[0].aval)->value.fval);
            (yyval.aval) = (yyvsp[0].aval);
        } else {
            if (isNumericType((yyvsp[0].aval)->type)) {
                struct Address *zero;
                int base = getBaseType((yyvsp[0].aval)->type);
                if (base == 2 || base == 3) {
                    zero = makeAddress(FLTCONST, base);
                    zero->value.fval = 0.0;
                } else {
                    zero = makeAddress(INTCONST, base);
                    zero->value.ival = 0;
                }
                (yyval.aval) = emitBinaryOp(zero, (yyvsp[0].aval), '-');
                freeAddress(zero);
                freeAddress((yyvsp[0].aval));
            } else {
                fprintf(stderr, "Error: Unary minus on non-numeric type\n");
                freeAddress((yyvsp[0].aval));
                YYABORT;
            }
        }
    }
#line 1946 "y.tab.c"
    break;

  case 50: /* ITEM: D1 SMPLITEM  */
#line 555 "claude.y"
        {
            (yyval.aval) = (yyvsp[0].aval);
        }
#line 1954 "y.tab.c"
    break;

  case 51: /* ITEM: ITEM '.' D2 SMPLITEM  */
#line 559 "claude.y"
        {
            printf("[ITEM.DOT] Accessing struct member. Base type %d, Field type %d\n", (yyvsp[-3].aval)->type, (yyvsp[0].aval)->type); 
            
            struct Address *base = (yyvsp[-3].aval);
            struct Address *field = (yyvsp[0].aval);
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
            (yyval.aval) = result;
        }
#line 1991 "y.tab.c"
    break;

  case 52: /* D1: %empty  */
#line 593 "claude.y"
        {
            (yyval.tval) = 0;
        }
#line 1999 "y.tab.c"
    break;

  case 53: /* D2: %empty  */
#line 600 "claude.y"
        {
            struct Address *item = (yyvsp[(-1) - (0)].aval);
            int item_type = item->type;
            
            if (TT[item_type].category != STRUCTURE) {
                fprintf(stderr, "Error: Dot operator used on non-structure type\n");
                YYABORT;
            }
            
            (yyval.tval) = TT[item_type].reference;
            printf("[MARKER_ST] Found DOT. Base item is type %d (struct). Setting table to %d\n", item_type, (yyval.tval)); 
        }
#line 2016 "y.tab.c"
    break;

  case 54: /* SMPLITEM: ID  */
#line 616 "claude.y"
        {
            int table_no = 0;
            
            if ((yyvsp[-1].tval) > 0 && (yyvsp[-1].tval) < NumTables) {
                table_no = (yyvsp[-1].tval);
                printf("----Hello i set the table here %d\n", table_no); 
            }
            
            int sym_idx = lookupSymbol((yyvsp[0].sval), table_no);
            if (sym_idx == -1) {
                fprintf(stderr, "Error: Undefined variable '%s' in table %d\n", (yyvsp[0].sval), table_no);
                free((yyvsp[0].sval));
                YYABORT;
            }
            
            (yyval.aval) = makeAddress(OFFSET, ST_table[table_no][sym_idx].type);
            (yyval.aval)->value.offset = ST_table[table_no][sym_idx].offset;
            printf("[SMPLITEM] Found ID '%s' in table %d. Type: %d, Offset: %d\n", (yyvsp[0].sval), table_no, (yyval.aval)->type, (yyval.aval)->value.offset); 
            free((yyvsp[0].sval));
        }
#line 2041 "y.tab.c"
    break;

  case 55: /* SMPLITEM: AREF  */
#line 637 "claude.y"
        {
            (yyval.aval) = (yyvsp[0].aval);
        }
#line 2049 "y.tab.c"
    break;

  case 56: /* AREF: AREF '[' EXPR ']'  */
#line 644 "claude.y"
        {
            struct Address *arr = (yyvsp[-3].aval);
            struct Address *idx = (yyvsp[-1].aval);
            
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
            
            (yyval.aval) = result;
        }
#line 2112 "y.tab.c"
    break;

  case 57: /* AREF: ID '[' EXPR ']'  */
#line 703 "claude.y"
        {
            int table_no = 0;
            
            if ((yyvsp[-4].tval) > 0 && (yyvsp[-4].tval) < NumTables) {
                int table2 = (yyvsp[-4].tval);
                table_no = (yyvsp[-4].tval);
                printf("----br br br Hello i set the table ID EXPR to %d\n", table2); 
            }
            
            int sym_idx = lookupSymbol((yyvsp[-3].sval), table_no);
            if (sym_idx == -1) {
                fprintf(stderr, "Error: in AREF Undefined variable '%s' in table %d\n", (yyvsp[-3].sval), table_no);
                free((yyvsp[-3].sval));
                freeAddress((yyvsp[-1].aval));
                YYABORT;
            }
            
            int arr_type = ST_table[table_no][sym_idx].type;
            
            if (TT[arr_type].category != ARR) {
                fprintf(stderr, "Error: Subscript operator on non-array\n");
                free((yyvsp[-3].sval));
                freeAddress((yyvsp[-1].aval));
                YYABORT;
            }
            
            int elem_type = TT[arr_type].reference;
            int elem_width = TT[elem_type].width;
            int base_offset = ST_table[table_no][sym_idx].offset;
            
            printf("[AREF] ID array access: '%s' in table %d. Array type %d, Index type %d. Elem type %d\n", (yyvsp[-3].sval), table_no, arr_type, (yyvsp[-1].aval)->type, elem_type); 

            struct Address *idx = (yyvsp[-1].aval);
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
            free((yyvsp[-3].sval));
            
            (yyval.aval) = result;
        }
#line 2185 "y.tab.c"
    break;

  case 58: /* BOOL: BOOL OR M BOOL  */
#line 775 "claude.y"
        {
            backpatch((yyvsp[-3].boolval)->false_list, (yyvsp[-3].boolval)->false_count, (yyvsp[-1].mval)->instr);
            (yyval.boolval) = (struct Boolean*)malloc(sizeof(struct Boolean));
            (yyval.boolval)->true_count = 0;
            (yyval.boolval)->false_count = 0;
            merge((yyval.boolval)->true_list, &((yyval.boolval)->true_count), (yyvsp[-3].boolval)->true_list, (yyvsp[-3].boolval)->true_count);
            merge((yyval.boolval)->true_list, &((yyval.boolval)->true_count), (yyvsp[0].boolval)->true_list, (yyvsp[0].boolval)->true_count);
            merge((yyval.boolval)->false_list, &((yyval.boolval)->false_count), (yyvsp[0].boolval)->false_list, (yyvsp[0].boolval)->false_count);
            printf("[BOOL] Boolean op: OR\n");
            free((yyvsp[-3].boolval));
            free((yyvsp[-1].mval));
            free((yyvsp[0].boolval));
        }
#line 2203 "y.tab.c"
    break;

  case 59: /* BOOL: BOOL AND M BOOL  */
#line 789 "claude.y"
        {
            backpatch((yyvsp[-3].boolval)->true_list, (yyvsp[-3].boolval)->true_count, (yyvsp[-1].mval)->instr);
            (yyval.boolval) = (struct Boolean*)malloc(sizeof(struct Boolean));
            (yyval.boolval)->true_count = 0;
            (yyval.boolval)->false_count = 0;
            merge((yyval.boolval)->false_list, &((yyval.boolval)->false_count), (yyvsp[-3].boolval)->false_list, (yyvsp[-3].boolval)->false_count);
            merge((yyval.boolval)->false_list, &((yyval.boolval)->false_count), (yyvsp[0].boolval)->false_list, (yyvsp[0].boolval)->false_count);
            merge((yyval.boolval)->true_list, &((yyval.boolval)->true_count), (yyvsp[0].boolval)->true_list, (yyvsp[0].boolval)->true_count);
            printf("[BOOL] Boolean op: AND\n");
            free((yyvsp[-3].boolval));
            free((yyvsp[-1].mval));
            free((yyvsp[0].boolval));
        }
#line 2221 "y.tab.c"
    break;

  case 60: /* BOOL: NOT BOOL  */
#line 803 "claude.y"
        {
            (yyval.boolval) = (struct Boolean*)malloc(sizeof(struct Boolean));
            (yyval.boolval)->true_count = (yyvsp[0].boolval)->false_count;
            (yyval.boolval)->false_count = (yyvsp[0].boolval)->true_count;
            memcpy((yyval.boolval)->true_list, (yyvsp[0].boolval)->false_list, (yyvsp[0].boolval)->false_count * sizeof(int));
            memcpy((yyval.boolval)->false_list, (yyvsp[0].boolval)->true_list, (yyvsp[0].boolval)->true_count * sizeof(int));
            printf("[BOOL] Boolean op: NOT\n");
            free((yyvsp[0].boolval));
        }
#line 2235 "y.tab.c"
    break;

  case 61: /* BOOL: '(' BOOL ')'  */
#line 813 "claude.y"
        {
            printf("[BOOL] Parenthesized BOOL\n");
            (yyval.boolval) = (yyvsp[-1].boolval);
        }
#line 2244 "y.tab.c"
    break;

  case 62: /* BOOL: EXPR RELOP EXPR  */
#line 818 "claude.y"
        {
            printf("[BOOL] Relational op\n");
            
            struct Address *left_loaded = (yyvsp[-2].aval);
            if ((yyvsp[-2].aval)->category != INTCONST && (yyvsp[-2].aval)->category != FLTCONST) {
                left_loaded = loadToTemp((yyvsp[-2].aval));
            }
            
            struct Address *right_loaded = (yyvsp[0].aval);
            if ((yyvsp[0].aval)->category != INTCONST && (yyvsp[0].aval)->category != FLTCONST) {
                right_loaded = loadToTemp((yyvsp[0].aval));
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
            switch((yyvsp[-1].rval)) {
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
            
            (yyval.boolval) = (struct Boolean*)malloc(sizeof(struct Boolean));
            (yyval.boolval)->true_count = 1;
            (yyval.boolval)->true_list[0] = instr_count;
            (yyval.boolval)->false_count = 1;
            (yyval.boolval)->false_list[0] = instr_count + 1;
            
            emit(buf);
            int goto_instr = emit("      goto "); 
            leaders[goto_instr] = 1; 
            
            if (left_loaded != (yyvsp[-2].aval)) freeAddress(left_loaded);
            if (right_loaded != (yyvsp[0].aval)) freeAddress(right_loaded);
            freeAddress(left_op);
            freeAddress(right_op);
            freeAddress((yyvsp[-2].aval));
            freeAddress((yyvsp[0].aval));
        }
#line 2318 "y.tab.c"
    break;

  case 63: /* RELOP: RELEQ  */
#line 890 "claude.y"
                 { (yyval.rval) = 1; printf("[RELOP] Found RELEQ (==)\n"); }
#line 2324 "y.tab.c"
    break;

  case 64: /* RELOP: RELNEQ  */
#line 891 "claude.y"
                 { (yyval.rval) = 2; printf("[RELOP] Found RELNEQ (!=)\n"); }
#line 2330 "y.tab.c"
    break;

  case 65: /* RELOP: RELLT  */
#line 892 "claude.y"
                 { (yyval.rval) = 3; printf("[RELOP] Found RELLT (<)\n"); }
#line 2336 "y.tab.c"
    break;

  case 66: /* RELOP: RELLTE  */
#line 893 "claude.y"
                 { (yyval.rval) = 4; printf("[RELOP] Found RELLTE (<=)\n"); }
#line 2342 "y.tab.c"
    break;

  case 67: /* RELOP: RELGT  */
#line 894 "claude.y"
                 { (yyval.rval) = 5; printf("[RELOP] Found RELGT (>)\n"); }
#line 2348 "y.tab.c"
    break;

  case 68: /* RELOP: RELGTE  */
#line 895 "claude.y"
                 { (yyval.rval) = 6; printf("[RELOP] Found RELGTE (>=)\n"); }
#line 2354 "y.tab.c"
    break;


#line 2358 "y.tab.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      yyerror (YY_("syntax error"));
    }

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

#line 898 "claude.y"


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
