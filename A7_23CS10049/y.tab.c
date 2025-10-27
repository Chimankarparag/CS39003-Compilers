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


#line 183 "y.tab.c"

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
    DOT = 266                      /* DOT  */
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
#define DOT 266

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 113 "claude.y"

    long long ival;
    char *sval;
    double fval;
    struct BaseInfo *bval;
    struct Address *aval;
    int tval;  // for table numbers

#line 267 "y.tab.c"

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
  YYSYMBOL_DOT = 11,                       /* DOT  */
  YYSYMBOL_12_ = 12,                       /* ';'  */
  YYSYMBOL_13_ = 13,                       /* '{'  */
  YYSYMBOL_14_ = 14,                       /* '}'  */
  YYSYMBOL_15_ = 15,                       /* ','  */
  YYSYMBOL_16_ = 16,                       /* '['  */
  YYSYMBOL_17_ = 17,                       /* ']'  */
  YYSYMBOL_18_ = 18,                       /* '='  */
  YYSYMBOL_19_ = 19,                       /* '+'  */
  YYSYMBOL_20_ = 20,                       /* '-'  */
  YYSYMBOL_21_ = 21,                       /* '*'  */
  YYSYMBOL_22_ = 22,                       /* '/'  */
  YYSYMBOL_23_ = 23,                       /* '%'  */
  YYSYMBOL_24_ = 24,                       /* '('  */
  YYSYMBOL_25_ = 25,                       /* ')'  */
  YYSYMBOL_YYACCEPT = 26,                  /* $accept  */
  YYSYMBOL_PROG = 27,                      /* PROG  */
  YYSYMBOL_N1 = 28,                        /* N1  */
  YYSYMBOL_DECLIST = 29,                   /* DECLIST  */
  YYSYMBOL_N2 = 30,                        /* N2  */
  YYSYMBOL_N3 = 31,                        /* N3  */
  YYSYMBOL_DECL = 32,                      /* DECL  */
  YYSYMBOL_N4 = 33,                        /* N4  */
  YYSYMBOL_W1 = 34,                        /* W1  */
  YYSYMBOL_C1 = 35,                        /* C1  */
  YYSYMBOL_C2 = 36,                        /* C2  */
  YYSYMBOL_BASIC = 37,                     /* BASIC  */
  YYSYMBOL_VARLIST = 38,                   /* VARLIST  */
  YYSYMBOL_M1 = 39,                        /* M1  */
  YYSYMBOL_M2 = 40,                        /* M2  */
  YYSYMBOL_M3 = 41,                        /* M3  */
  YYSYMBOL_M4 = 42,                        /* M4  */
  YYSYMBOL_VAR = 43,                       /* VAR  */
  YYSYMBOL_DIMS = 44,                      /* DIMS  */
  YYSYMBOL_STMTLIST = 45,                  /* STMTLIST  */
  YYSYMBOL_STMT = 46,                      /* STMT  */
  YYSYMBOL_ASGN = 47,                      /* ASGN  */
  YYSYMBOL_EXPR = 48,                      /* EXPR  */
  YYSYMBOL_TERM = 49,                      /* TERM  */
  YYSYMBOL_FACTOR = 50,                    /* FACTOR  */
  YYSYMBOL_ITEM = 51,                      /* ITEM  */
  YYSYMBOL_MARKER_ST = 52,                 /* MARKER_ST  */
  YYSYMBOL_SMPLITEM = 53,                  /* SMPLITEM  */
  YYSYMBOL_AREF = 54                       /* AREF  */
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
#define YYLAST   64

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  26
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  29
/* YYNRULES -- Number of rules.  */
#define YYNRULES  50
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  80

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   266


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
       2,     2,     2,     2,     2,     2,     2,    23,     2,     2,
      24,    25,    21,    19,    15,    20,     2,    22,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,    12,
       2,    18,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,    16,     2,    17,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,    13,     2,    14,     2,     2,     2,     2,
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
       5,     6,     7,     8,     9,    10,    11
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,   138,   138,   143,   149,   153,   159,   164,   170,   174,
     178,   183,   190,   198,   207,   221,   236,   237,   238,   239,
     243,   244,   247,   253,   258,   263,   269,   285,   286,   299,
     301,   305,   309,   325,   331,   337,   344,   350,   356,   362,
     369,   374,   379,   383,   390,   394,   434,   450,   472,   479,
     526
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
  "STRUCT", "LNG", "INT", "FLT", "DBL", "DOT", "';'", "'{'", "'}'", "','",
  "'['", "']'", "'='", "'+'", "'-'", "'*'", "'/'", "'%'", "'('", "')'",
  "$accept", "PROG", "N1", "DECLIST", "N2", "N3", "DECL", "N4", "W1", "C1",
  "C2", "BASIC", "VARLIST", "M1", "M2", "M3", "M4", "VAR", "DIMS",
  "STMTLIST", "STMT", "ASGN", "EXPR", "TERM", "FACTOR", "ITEM",
  "MARKER_ST", "SMPLITEM", "AREF", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-40)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-30)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int8 yypact[] =
{
     -40,    16,   -40,   -40,    31,    20,    20,    15,    29,   -40,
     -40,   -40,   -40,   -40,   -40,   -40,    26,   -40,   -40,    -1,
     -40,    35,    28,    36,    -2,   -40,    -2,    -2,   -40,    36,
     -40,    21,   -40,   -40,   -40,    -2,   -11,    22,   -40,    41,
      15,    -5,     4,   -40,    23,    37,   -40,   -40,     0,   -40,
      -2,    -2,    -2,    -2,    -2,   -40,   -40,   -40,    33,   -40,
      50,   -40,    36,   -40,    22,    22,   -40,   -40,   -40,    42,
      38,   -40,    45,   -40,   -40,    36,    37,    25,   -40,   -40
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       3,     0,     6,     1,     7,     0,     0,     2,     0,    17,
      16,    18,    19,     4,    22,     5,    47,    30,    31,     0,
      44,    48,    15,     0,     0,    46,     0,     0,    12,     0,
      24,     0,    20,    40,    41,     0,     0,    35,    39,    42,
       0,     0,     0,     6,     0,    27,     8,    23,     0,    50,
       0,     0,     0,     0,     0,    45,    32,    49,     7,    11,
       0,    26,     0,    43,    33,    34,    36,    37,    38,     0,
       0,    21,    14,    25,     9,     0,    27,     0,    28,    10
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -40,   -40,   -40,    17,   -40,   -40,    52,   -40,   -40,   -40,
     -40,   -40,   -29,   -40,   -40,   -40,   -40,    -3,   -15,   -40,
     -40,   -40,   -22,   -39,    -4,    55,   -40,    24,   -40
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
       0,     1,     2,     4,     5,     6,    13,    43,    69,    75,
      29,    14,    31,    23,    62,    45,    76,    32,    61,     7,
      17,    18,    36,    37,    38,    39,    40,    20,    21
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int8 yytable[] =
{
      44,    16,    33,    34,    41,    42,    49,    56,    50,    51,
      25,    64,    65,    48,    50,    51,     3,    26,    16,    50,
      51,    57,    35,    50,    51,    63,     8,     9,    10,    11,
      12,   -29,    22,    46,   -29,    59,    47,    79,    47,    30,
      47,    28,    24,    52,    53,    54,    77,   -13,    66,    67,
      68,    27,    25,    60,    70,    73,    72,    74,    15,    71,
      58,    78,    19,     0,    55
};

static const yytype_int8 yycheck[] =
{
      29,     3,     4,     5,    26,    27,    17,    12,    19,    20,
      11,    50,    51,    35,    19,    20,     0,    18,     3,    19,
      20,    17,    24,    19,    20,    25,     6,     7,     8,     9,
      10,     0,     3,    12,     3,    12,    15,    12,    15,     3,
      15,    13,    16,    21,    22,    23,    75,    14,    52,    53,
      54,    16,    11,    16,     4,    17,    14,    12,     6,    62,
      43,    76,     7,    -1,    40
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,    27,    28,     0,    29,    30,    31,    45,     6,     7,
       8,     9,    10,    32,    37,    32,     3,    46,    47,    51,
      53,    54,     3,    39,    16,    11,    18,    16,    13,    36,
       3,    38,    43,     4,     5,    24,    48,    49,    50,    51,
      52,    48,    48,    33,    38,    41,    12,    15,    48,    17,
      19,    20,    21,    22,    23,    53,    12,    17,    29,    12,
      16,    44,    40,    25,    49,    49,    50,    50,    50,    34,
       4,    43,    14,    17,    12,    35,    42,    38,    44,    12
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr1[] =
{
       0,    26,    27,    28,    29,    29,    30,    31,    32,    32,
      32,    32,    33,    34,    35,    36,    37,    37,    37,    37,
      38,    38,    39,    40,    41,    42,    43,    44,    44,    45,
      45,    46,    47,    48,    48,    48,    49,    49,    49,    49,
      50,    50,    50,    50,    51,    51,    52,    53,    53,    54,
      54
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     3,     0,     2,     3,     0,     0,     4,     8,
      10,     5,     0,     0,     0,     0,     1,     1,     1,     1,
       1,     4,     0,     0,     0,     0,     3,     0,     5,     0,
       2,     1,     4,     3,     3,     1,     3,     3,     3,     1,
       1,     1,     1,     3,     1,     4,     0,     1,     1,     4,
       4
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
#line 138 "claude.y"
                            { 
            printf("+++ All declarations read\n\n"); 
        }
#line 1346 "y.tab.c"
    break;

  case 3: /* N1: %empty  */
#line 143 "claude.y"
        {
            (yyval.ival) = 0;
        }
#line 1354 "y.tab.c"
    break;

  case 4: /* DECLIST: N2 DECL  */
#line 150 "claude.y"
        {

        }
#line 1362 "y.tab.c"
    break;

  case 5: /* DECLIST: DECLIST N3 DECL  */
#line 154 "claude.y"
        {

        }
#line 1370 "y.tab.c"
    break;

  case 6: /* N2: %empty  */
#line 159 "claude.y"
        {
            (yyval.ival) = (yyvsp[0].ival); 
        }
#line 1378 "y.tab.c"
    break;

  case 7: /* N3: %empty  */
#line 164 "claude.y"
        {
            (yyval.ival) = (yyvsp[(-1) - (0)].ival); 
        }
#line 1386 "y.tab.c"
    break;

  case 8: /* DECL: BASIC M1 VARLIST ';'  */
#line 171 "claude.y"
        {
            freeBaseInfo((yyvsp[-2].bval));
        }
#line 1394 "y.tab.c"
    break;

  case 9: /* DECL: STRUCT ID '{' N4 DECLIST W1 '}' ';'  */
#line 175 "claude.y"
        {
            free((yyvsp[-6].sval));
        }
#line 1402 "y.tab.c"
    break;

  case 10: /* DECL: STRUCT ID '{' N4 DECLIST W1 '}' C1 VARLIST ';'  */
#line 179 "claude.y"
        {
            freeBaseInfo((yyvsp[-2].bval));
            free((yyvsp[-8].sval));
        }
#line 1411 "y.tab.c"
    break;

  case 11: /* DECL: STRUCT ID C2 VARLIST ';'  */
#line 184 "claude.y"
        { 
            freeBaseInfo((yyvsp[-2].bval));
            free((yyvsp[-3].sval));
        }
#line 1420 "y.tab.c"
    break;

  case 12: /* N4: %empty  */
#line 190 "claude.y"
        {
            (yyval.ival) = NumTables++; 
            int struct_type = addStructTypeWithTable((yyvsp[(-1) - (0)].sval), (yyval.ival));
            ST_count[(yyval.ival)] = 0;
            ST_width[(yyval.ival)] = 0;
        }
#line 1431 "y.tab.c"
    break;

  case 13: /* W1: %empty  */
#line 198 "claude.y"
        {
            (yyval.ival) = ST_width[(yyvsp[(-1) - (0)].ival)]; 
            (yyval.ival) = align4((yyval.ival));  
            int struct_type = lookupStructType((yyvsp[(-3) - (0)].sval));
            if (struct_type != -1)
                TT[struct_type].width = (yyval.ival); 
        }
#line 1443 "y.tab.c"
    break;

  case 14: /* C1: %empty  */
#line 207 "claude.y"
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
        }
#line 1460 "y.tab.c"
    break;

  case 15: /* C2: %empty  */
#line 221 "claude.y"
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
        }
#line 1477 "y.tab.c"
    break;

  case 16: /* BASIC: INT  */
#line 236 "claude.y"
           { (yyval.ival) = 0; }
#line 1483 "y.tab.c"
    break;

  case 17: /* BASIC: LNG  */
#line 237 "claude.y"
            { (yyval.ival) = 1; }
#line 1489 "y.tab.c"
    break;

  case 18: /* BASIC: FLT  */
#line 238 "claude.y"
            { (yyval.ival) = 2; }
#line 1495 "y.tab.c"
    break;

  case 19: /* BASIC: DBL  */
#line 239 "claude.y"
            { (yyval.ival) = 3; }
#line 1501 "y.tab.c"
    break;

  case 22: /* M1: %empty  */
#line 247 "claude.y"
        {
            (yyval.bval) = makeBaseInfo((yyvsp[0].ival)); 
            (yyval.bval)->b_tablerow = (yyvsp[(-1) - (0)].ival);
        }
#line 1510 "y.tab.c"
    break;

  case 23: /* M2: %empty  */
#line 253 "claude.y"
        {
            (yyval.bval) = (yyvsp[(-2) - (0)].bval); 
        }
#line 1518 "y.tab.c"
    break;

  case 24: /* M3: %empty  */
#line 258 "claude.y"
        {
            (yyval.bval) = (yyvsp[(-1) - (0)].bval); 
        }
#line 1526 "y.tab.c"
    break;

  case 25: /* M4: %empty  */
#line 263 "claude.y"
        {
            (yyval.bval) = (yyvsp[(-3) - (0)].bval);
        }
#line 1534 "y.tab.c"
    break;

  case 26: /* VAR: ID M3 DIMS  */
#line 270 "claude.y"
    {
        struct BaseInfo *base_info = (yyvsp[-1].bval);
        int base = base_info->b_type;
        int table_no = base_info->b_tablerow;
        int t = base;

        if ((yyvsp[0].ival) != -1) {
            t = (yyvsp[0].ival);
        }
        addSymbolByName((yyvsp[-2].sval), t, table_no);
        free((yyvsp[-2].sval));
    }
#line 1551 "y.tab.c"
    break;

  case 27: /* DIMS: %empty  */
#line 285 "claude.y"
        { (yyval.ival) = -1; }
#line 1557 "y.tab.c"
    break;

  case 28: /* DIMS: '[' NUM ']' M4 DIMS  */
#line 287 "claude.y"
        {
            int reftype;
            if ((yyvsp[0].ival) == -1) {
                struct BaseInfo *b = (yyvsp[-1].bval);
                reftype = b->b_type;
            } else {
                reftype = (yyvsp[0].ival);
            }
            (yyval.ival) = addArrayType((yyvsp[-3].ival), reftype);
        }
#line 1572 "y.tab.c"
    break;

  case 32: /* ASGN: ITEM '=' EXPR ';'  */
#line 310 "claude.y"
        {
            // Check if ITEM is a valid l-value
            if (!isNumericType((yyvsp[-3].aval)->type)) {
                fprintf(stderr, "*** Error: invalid type of l-value\n");
                freeAddress((yyvsp[-3].aval));
                freeAddress((yyvsp[-1].aval));
                YYABORT;
            }
            emitAssign((yyvsp[-3].aval), (yyvsp[-1].aval));
            freeAddress((yyvsp[-3].aval));
            freeAddress((yyvsp[-1].aval));
        }
#line 1589 "y.tab.c"
    break;

  case 33: /* EXPR: EXPR '+' TERM  */
#line 326 "claude.y"
        {
            (yyval.aval) = emitBinaryOp((yyvsp[-2].aval), (yyvsp[0].aval), '+');
            freeAddress((yyvsp[-2].aval));
            freeAddress((yyvsp[0].aval));
        }
#line 1599 "y.tab.c"
    break;

  case 34: /* EXPR: EXPR '-' TERM  */
#line 332 "claude.y"
        {
            (yyval.aval) = emitBinaryOp((yyvsp[-2].aval), (yyvsp[0].aval), '-');
            freeAddress((yyvsp[-2].aval));
            freeAddress((yyvsp[0].aval));
        }
#line 1609 "y.tab.c"
    break;

  case 35: /* EXPR: TERM  */
#line 338 "claude.y"
        {
            (yyval.aval) = (yyvsp[0].aval);
        }
#line 1617 "y.tab.c"
    break;

  case 36: /* TERM: TERM '*' FACTOR  */
#line 345 "claude.y"
        {
            (yyval.aval) = emitBinaryOp((yyvsp[-2].aval), (yyvsp[0].aval), '*');
            freeAddress((yyvsp[-2].aval));
            freeAddress((yyvsp[0].aval));
        }
#line 1627 "y.tab.c"
    break;

  case 37: /* TERM: TERM '/' FACTOR  */
#line 351 "claude.y"
        {
            (yyval.aval) = emitBinaryOp((yyvsp[-2].aval), (yyvsp[0].aval), '/');
            freeAddress((yyvsp[-2].aval));
            freeAddress((yyvsp[0].aval));
        }
#line 1637 "y.tab.c"
    break;

  case 38: /* TERM: TERM '%' FACTOR  */
#line 357 "claude.y"
        {
            (yyval.aval) = emitBinaryOp((yyvsp[-2].aval), (yyvsp[0].aval), '%');
            freeAddress((yyvsp[-2].aval));
            freeAddress((yyvsp[0].aval));
        }
#line 1647 "y.tab.c"
    break;

  case 39: /* TERM: FACTOR  */
#line 363 "claude.y"
        {
            (yyval.aval) = (yyvsp[0].aval);
        }
#line 1655 "y.tab.c"
    break;

  case 40: /* FACTOR: NUM  */
#line 370 "claude.y"
        {
            (yyval.aval) = makeAddress(INTCONST, 0); // type 0 = int
            (yyval.aval)->value.ival = (yyvsp[0].ival);
        }
#line 1664 "y.tab.c"
    break;

  case 41: /* FACTOR: FLTCNST  */
#line 375 "claude.y"
        {
            (yyval.aval) = makeAddress(FLTCONST, 3); // type 3 = double
            (yyval.aval)->value.fval = (yyvsp[0].fval);
        }
#line 1673 "y.tab.c"
    break;

  case 42: /* FACTOR: ITEM  */
#line 380 "claude.y"
        {
            (yyval.aval) = (yyvsp[0].aval);
        }
#line 1681 "y.tab.c"
    break;

  case 43: /* FACTOR: '(' EXPR ')'  */
#line 384 "claude.y"
        {
            (yyval.aval) = (yyvsp[-1].aval);
        }
#line 1689 "y.tab.c"
    break;

  case 44: /* ITEM: SMPLITEM  */
#line 391 "claude.y"
        {
            (yyval.aval) = (yyvsp[0].aval);
        }
#line 1697 "y.tab.c"
    break;

  case 45: /* ITEM: ITEM DOT MARKER_ST SMPLITEM  */
#line 395 "claude.y"
        {
            // $1 is the structure item
            // $3 is the symbol table number for the structure
            // $4 is the field within the structure
            
            struct Address *base = (yyvsp[-3].aval);
            struct Address *field = (yyvsp[0].aval);
            
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
            (yyval.aval) = result;
        }
#line 1737 "y.tab.c"
    break;

  case 46: /* MARKER_ST: %empty  */
#line 434 "claude.y"
        {
            // Get the type of ITEM on the left of DOT
            struct Address *item = (yyvsp[(-1) - (0)].aval);
            int item_type = item->type;
            
            if (TT[item_type].category != STRUCTURE) {
                fprintf(stderr, "Error: Dot operator used on non-structure type\n");
                YYABORT;
            }
            
            // Set the symbol table number for SMPLITEM lookup
            (yyval.tval) = TT[item_type].reference;
        }
#line 1755 "y.tab.c"
    break;

  case 47: /* SMPLITEM: ID  */
#line 451 "claude.y"
        {
            // Determine which symbol table to use
            int table_no = 0; // Default to global
            
            // Check if we're in a structure context (after DOT)
            // If MARKER_ST is on the stack at position -1, use it
            if ((yyvsp[(-1) - (1)].tval) > 0 && (yyvsp[(-1) - (1)].tval) < NumTables) {
                table_no = (yyvsp[(-1) - (1)].tval);
            }
            
            int sym_idx = lookupSymbol((yyvsp[0].sval), table_no);
            if (sym_idx == -1) {
                fprintf(stderr, "Error: Undefined variable '%s'\n", (yyvsp[0].sval));
                free((yyvsp[0].sval));
                YYABORT;
            }
            
            (yyval.aval) = makeAddress(OFFSET, ST_table[table_no][sym_idx].type);
            (yyval.aval)->value.offset = ST_table[table_no][sym_idx].offset;
            free((yyvsp[0].sval));
        }
#line 1781 "y.tab.c"
    break;

  case 48: /* SMPLITEM: AREF  */
#line 473 "claude.y"
        {
            (yyval.aval) = (yyvsp[0].aval);
        }
#line 1789 "y.tab.c"
    break;

  case 49: /* AREF: AREF '[' EXPR ']'  */
#line 480 "claude.y"
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
            
            (yyval.aval) = result;
        }
#line 1840 "y.tab.c"
    break;

  case 50: /* AREF: ID '[' EXPR ']'  */
#line 527 "claude.y"
        {
            // Determine which symbol table to use
            int table_no = 0; // Default to global
            
            // Check if we're in a structure context
            if ((yyvsp[(-3) - (4)].tval) > 0 && (yyvsp[(-3) - (4)].tval) < NumTables) {
                table_no = (yyvsp[(-3) - (4)].tval);
            }
            
            int sym_idx = lookupSymbol((yyvsp[-3].sval), table_no);
            if (sym_idx == -1) {
                fprintf(stderr, "Error: Undefined variable '%s'\n", (yyvsp[-3].sval));
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
            
            struct Address *idx = (yyvsp[-1].aval);
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
            free((yyvsp[-3].sval));
            
            (yyval.aval) = result;
        }
#line 1900 "y.tab.c"
    break;


#line 1904 "y.tab.c"

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

#line 584 "claude.y"


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
