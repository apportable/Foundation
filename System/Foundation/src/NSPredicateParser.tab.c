/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

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

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.3"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 1

/* Using locations.  */
#define YYLSP_NEEDED 0

/* Substitute the variable and function names.  */
#define yyparse predicate_parse
#define yylex   predicate_lex
#define yyerror predicate_error
#define yylval  predicate_lval
#define yychar  predicate_char
#define yydebug predicate_debug
#define yynerrs predicate_nerrs


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     LPAREN = 258,
     RPAREN = 259,
     LCURLY = 260,
     RCURLY = 261,
     LSQUARE = 262,
     RSQUARE = 263,
     EQUAL = 264,
     NOT_EQUAL = 265,
     LESS_THAN = 266,
     GREATER_THAN = 267,
     LESS_THAN_OR_EQUAL = 268,
     GREATER_THAN_OR_EQUAL = 269,
     AND = 270,
     OR = 271,
     NOT = 272,
     PERIOD = 273,
     MINUS = 274,
     PLUS = 275,
     DIVIDE = 276,
     TIMES = 277,
     POWER = 278,
     ASSIGN = 279,
     COMMA = 280,
     DOLLAR = 281,
     PERCENT = 282,
     BETWEEN = 283,
     CONTAINS = 284,
     IN = 285,
     BEGINS_WITH = 286,
     ENDS_WITH = 287,
     LIKE = 288,
     MATCHES = 289,
     ANY = 290,
     ALL = 291,
     NONE = 292,
     SOME = 293,
     TRUE_PREDICATE = 294,
     FALSE_PREDICATE = 295,
     NULL_TOK = 296,
     TRUE_TOK = 297,
     FALSE_TOK = 298,
     SELF = 299,
     FIRST = 300,
     LAST = 301,
     SIZE = 302,
     AT = 303,
     NUMBER = 304,
     STRING = 305,
     IDENTIFIER = 306
   };
#endif
/* Tokens.  */
#define LPAREN 258
#define RPAREN 259
#define LCURLY 260
#define RCURLY 261
#define LSQUARE 262
#define RSQUARE 263
#define EQUAL 264
#define NOT_EQUAL 265
#define LESS_THAN 266
#define GREATER_THAN 267
#define LESS_THAN_OR_EQUAL 268
#define GREATER_THAN_OR_EQUAL 269
#define AND 270
#define OR 271
#define NOT 272
#define PERIOD 273
#define MINUS 274
#define PLUS 275
#define DIVIDE 276
#define TIMES 277
#define POWER 278
#define ASSIGN 279
#define COMMA 280
#define DOLLAR 281
#define PERCENT 282
#define BETWEEN 283
#define CONTAINS 284
#define IN 285
#define BEGINS_WITH 286
#define ENDS_WITH 287
#define LIKE 288
#define MATCHES 289
#define ANY 290
#define ALL 291
#define NONE 292
#define SOME 293
#define TRUE_PREDICATE 294
#define FALSE_PREDICATE 295
#define NULL_TOK 296
#define TRUE_TOK 297
#define FALSE_TOK 298
#define SELF 299
#define FIRST 300
#define LAST 301
#define SIZE 302
#define AT 303
#define NUMBER 304
#define STRING 305
#define IDENTIFIER 306




/* Copy the first part of user declarations.  */
// #line 1 "NSPredicateParser.ym"

    #import <Foundation/NSPredicate.h>
    #import <Foundation/NSCompoundPredicate.h>
    #import <Foundation/NSComparisonPredicate.h>
    #import <Foundation/NSExpression.h>
    #import <Foundation/NSNull.h>
    #import "NSPredicateInternal.h"
    #import "NSExpressionInternal.h"

    #import "NSPredicateParser.tab.h"
    #import "NSPredicateLexer.h"

    typedef NSExpression *(^argBlock)(NSString *formatType);

    CF_PRIVATE int predicate_parse(yyscan_t lexer, argBlock args, NSPredicate **predicate);

    extern void _predicate_lexer_create(const char *string, yyscan_t *lexer, YY_BUFFER_STATE *state);
    extern void _predicate_lexer_destroy(yyscan_t lexer, YY_BUFFER_STATE state);

    static void predicate_error(yyscan_t scanner, argBlock args, NSPredicate **predicate, const char *error);

    static NSTruePredicate *truePredicate;
    static NSFalsePredicate *falsePredicate;

    static NSConstantValueExpression *zeroExpression;
    static NSConstantValueExpression *nullExpression;
    static NSConstantValueExpression *yesExpression;
    static NSConstantValueExpression *noExpression;

    static NSSymbolicExpression *firstExpression;
    static NSSymbolicExpression *lastExpression;
    static NSSymbolicExpression *sizeExpression;

    static NSSelfExpression *selfExpression;

    static SEL add_to_;
    static SEL from_subtract_;
    static SEL multiply_by_;
    static SEL divide_by_;
    static SEL raise_toPower_;
    static SEL objectFrom_withIndex_;

    static NSFunctionExpression *binaryFunc(SEL selector, NSExpression *lhs, NSExpression *rhs);
    static NSExpression *concatKeypathExpressions(NSExpression *lhs, NSExpression *rhs);
    static SEL selectorFromIdentifier(NSString *name);
    static NSExpression *coerceObjectToExpression(argBlock args, NSString *formatType);
    static NSComparisonPredicateOptions parseComparisonOptions(NSString *optionString);

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wunreachable-code"


/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif

#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
// #line 66 "NSPredicateParser.ym"
{
    NSPredicate *predicate;
    NSExpression *expression;
    NSMutableArray *mutableArray;
    NSString *string;
    NSNumber *number;
    struct {
        NSExpression *lhs;
        NSExpression *rhs;
        NSPredicateOperatorType type;
        NSComparisonPredicateOptions options;
    } comparison;
    struct {
        NSPredicateOperatorType type;
        NSComparisonPredicateOptions options;
    } operator;
    NSMutableString *stringLiteral;
    NSPredicateOperatorType operatorType;
}
/* Line 193 of yacc.c.  */
// #line 278 "NSPredicateParser.tab.c"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */


/* Line 216 of yacc.c.  */
// #line 291 "NSPredicateParser.tab.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int i)
#else
static int
YYID (i)
    int i;
#endif
{
  return i;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

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
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
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
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss;
  YYSTYPE yyvs;
  };

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  49
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   251

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  52
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  17
/* YYNRULES -- Number of rules.  */
#define YYNRULES  68
/* YYNRULES -- Number of states.  */
#define YYNSTATES  104

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   306

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
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
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint8 yyprhs[] =
{
       0,     0,     3,     5,     7,     9,    11,    13,    17,    21,
      25,    28,    30,    33,    36,    39,    42,    46,    48,    50,
      52,    57,    59,    61,    63,    65,    67,    69,    71,    73,
      75,    77,    79,    81,    83,    87,    92,    96,    98,   100,
     104,   108,   112,   116,   120,   124,   127,   132,   134,   136,
     138,   140,   142,   145,   149,   151,   153,   156,   158,   160,
     162,   164,   166,   169,   173,   175,   179,   181,   183
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int8 yyrhs[] =
{
      53,     0,    -1,    54,    -1,    56,    -1,    55,    -1,    39,
      -1,    40,    -1,     3,    54,     4,    -1,    54,    15,    54,
      -1,    54,    16,    54,    -1,    17,    54,    -1,    57,    -1,
      35,    57,    -1,    38,    57,    -1,    36,    57,    -1,    37,
      57,    -1,    61,    58,    61,    -1,    28,    -1,    59,    -1,
      60,    -1,    60,     7,    51,     8,    -1,     9,    -1,    10,
      -1,    11,    -1,    12,    -1,    13,    -1,    14,    -1,    29,
      -1,    30,    -1,    31,    -1,    32,    -1,    33,    -1,    34,
      -1,    62,    -1,    51,     3,     4,    -1,    51,     3,    66,
       4,    -1,    68,    24,    61,    -1,    64,    -1,    65,    -1,
       3,    61,     4,    -1,    61,    23,    61,    -1,    61,    22,
      61,    -1,    61,    21,    61,    -1,    61,    20,    61,    -1,
      61,    19,    61,    -1,    19,    61,    -1,    61,     7,    63,
       8,    -1,    61,    -1,    45,    -1,    46,    -1,    47,    -1,
      51,    -1,    48,    51,    -1,    61,    18,    61,    -1,    50,
      -1,    49,    -1,    27,    67,    -1,    68,    -1,    41,    -1,
      42,    -1,    43,    -1,    44,    -1,     5,     6,    -1,     5,
      66,     6,    -1,    61,    -1,    66,    25,    61,    -1,    48,
      -1,    51,    -1,    26,    51,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   177,   177,   180,   181,   182,   183,   184,   187,   188,
     189,   192,   193,   194,   195,   196,   199,   202,   203,   206,
     207,   210,   211,   212,   213,   214,   215,   216,   217,   218,
     219,   220,   221,   224,   225,   226,   227,   228,   229,   230,
     233,   234,   235,   236,   237,   238,   239,   242,   243,   244,
     245,   248,   249,   250,   253,   254,   255,   256,   257,   258,
     259,   260,   261,   262,   265,   266,   269,   270,   273
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "LPAREN", "RPAREN", "LCURLY", "RCURLY",
  "LSQUARE", "RSQUARE", "EQUAL", "NOT_EQUAL", "LESS_THAN", "GREATER_THAN",
  "LESS_THAN_OR_EQUAL", "GREATER_THAN_OR_EQUAL", "AND", "OR", "NOT",
  "PERIOD", "MINUS", "PLUS", "DIVIDE", "TIMES", "POWER", "ASSIGN", "COMMA",
  "DOLLAR", "PERCENT", "BETWEEN", "CONTAINS", "IN", "BEGINS_WITH",
  "ENDS_WITH", "LIKE", "MATCHES", "ANY", "ALL", "NONE", "SOME",
  "TRUE_PREDICATE", "FALSE_PREDICATE", "NULL_TOK", "TRUE_TOK", "FALSE_TOK",
  "SELF", "FIRST", "LAST", "SIZE", "AT", "NUMBER", "STRING", "IDENTIFIER",
  "$accept", "Start", "Predicate", "CompoundPredicate",
  "ComparisonPredicate", "UnqualifiedComparisonPredicate", "Operator",
  "OperatorWithOptions", "OperatorType", "Expression", "BinaryExpression",
  "Index", "KeypathExpression", "ValueExpression", "ExpressionList",
  "Format", "Variable", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,   297,   298,   299,   300,   301,   302,   303,   304,
     305,   306
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    52,    53,    54,    54,    54,    54,    54,    55,    55,
      55,    56,    56,    56,    56,    56,    57,    58,    58,    59,
      59,    60,    60,    60,    60,    60,    60,    60,    60,    60,
      60,    60,    60,    61,    61,    61,    61,    61,    61,    61,
      62,    62,    62,    62,    62,    62,    62,    63,    63,    63,
      63,    64,    64,    64,    65,    65,    65,    65,    65,    65,
      65,    65,    65,    65,    66,    66,    67,    67,    68
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     1,     1,     1,     1,     1,     3,     3,     3,
       2,     1,     2,     2,     2,     2,     3,     1,     1,     1,
       4,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     3,     4,     3,     1,     1,     3,
       3,     3,     3,     3,     3,     2,     4,     1,     1,     1,
       1,     1,     2,     3,     1,     1,     2,     1,     1,     1,
       1,     1,     2,     3,     1,     3,     1,     1,     2
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     5,     6,    58,    59,    60,    61,     0,    55,    54,
      51,     0,     2,     4,     3,    11,     0,    33,    37,    38,
      57,     0,     0,     0,    62,    64,     0,    10,    45,    68,
      66,    67,    56,    12,    14,    15,    13,    52,     0,     1,
       0,     0,     0,    21,    22,    23,    24,    25,    26,     0,
       0,     0,     0,     0,     0,    17,    27,    28,    29,    30,
      31,    32,     0,    18,    19,     0,     7,    39,     0,    63,
       0,    34,     0,     8,     9,    48,    49,    50,    47,     0,
      53,    44,    43,    42,    41,    40,    16,     0,    36,    65,
      35,    46,     0,    20
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
      -1,    21,    22,    23,    24,    25,    72,    73,    74,    26,
      27,    89,    28,    29,    36,    42,    30
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -47
static const yytype_int16 yypact[] =
{
      61,    61,   120,    61,   172,   -46,   -41,   172,   172,   172,
     172,   -47,   -47,   -47,   -47,   -47,   -47,   -40,   -47,   -47,
      10,    20,    40,   -47,   -47,   -47,   217,   -47,   -47,   -47,
      -2,    53,     5,   172,   -47,    23,    -4,   -47,    27,   -47,
     -47,   -47,   -47,   -47,   -47,   -47,   -47,   -47,   139,   -47,
      61,    61,    87,   -47,   -47,   -47,   -47,   -47,   -47,   172,
     172,   172,   172,   172,   172,   -47,   -47,   -47,   -47,   -47,
     -47,   -47,   172,   -47,    24,   172,   -47,   -47,    63,   -47,
     172,   -47,     4,    36,   -47,   -47,   -47,   -47,    23,    32,
      96,    27,    27,    42,    42,   -47,    23,    21,   -47,    23,
     -47,   -47,    65,   -47
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
     -47,   -47,     3,   -47,   -47,   141,   -47,   -47,   -47,    -1,
     -47,   -47,   -47,   -47,    28,   -47,   -47
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -1
static const yytype_uint8 yytable[] =
{
      32,    35,    79,    38,    31,    39,    37,    40,   100,    77,
      41,    47,    52,    48,    53,    54,    55,    56,    57,    58,
      49,    80,    75,    59,    60,    61,    62,    63,    64,    80,
      52,    97,    78,    65,    66,    67,    68,    69,    70,    71,
     101,    59,    60,    61,    62,    63,    64,    35,    62,    63,
      64,    88,    51,    83,    84,    50,    51,    76,    90,    91,
      92,    93,    94,    95,     1,    64,     2,    77,    50,    51,
      52,    96,   102,   103,    98,     0,    82,     0,     3,    99,
       4,    59,    60,    61,    62,    63,    64,     5,     6,     0,
      33,     0,     2,     0,     0,     0,     7,     8,     9,    10,
      11,    12,    13,    14,    15,    16,     4,     0,     0,    17,
      18,    19,    20,     5,     6,    60,    61,    62,    63,    64,
       0,     0,     0,    33,     0,     2,    34,     0,    13,    14,
      15,    16,    85,    86,    87,    17,    18,    19,    20,     4,
       0,     0,    33,    81,     2,     0,     5,     6,    43,    44,
      45,    46,     0,     0,     0,     0,     0,     0,     4,     0,
       0,    13,    14,    15,    16,     5,     6,     0,    17,    18,
      19,    20,     0,     0,     0,    33,     0,     2,     0,     0,
      13,    14,    15,    16,     0,     0,     0,    17,    18,    19,
      20,     4,     0,     0,     0,     0,     0,     0,     5,     6,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    13,    14,    15,    16,     0,     0,     0,
      17,    18,    19,    20,    52,     0,    53,    54,    55,    56,
      57,    58,     0,     0,     0,    59,    60,    61,    62,    63,
      64,     0,     0,     0,     0,    65,    66,    67,    68,    69,
      70,    71
};

static const yytype_int8 yycheck[] =
{
       1,     2,     6,     4,     1,    51,     3,    48,     4,     4,
      51,    51,     7,     3,     9,    10,    11,    12,    13,    14,
       0,    25,    24,    18,    19,    20,    21,    22,    23,    25,
       7,     7,    33,    28,    29,    30,    31,    32,    33,    34,
       8,    18,    19,    20,    21,    22,    23,    48,    21,    22,
      23,    52,    16,    50,    51,    15,    16,     4,    59,    60,
      61,    62,    63,    64,     3,    23,     5,     4,    15,    16,
       7,    72,    51,     8,    75,    -1,    48,    -1,    17,    80,
      19,    18,    19,    20,    21,    22,    23,    26,    27,    -1,
       3,    -1,     5,    -1,    -1,    -1,    35,    36,    37,    38,
      39,    40,    41,    42,    43,    44,    19,    -1,    -1,    48,
      49,    50,    51,    26,    27,    19,    20,    21,    22,    23,
      -1,    -1,    -1,     3,    -1,     5,     6,    -1,    41,    42,
      43,    44,    45,    46,    47,    48,    49,    50,    51,    19,
      -1,    -1,     3,     4,     5,    -1,    26,    27,     7,     8,
       9,    10,    -1,    -1,    -1,    -1,    -1,    -1,    19,    -1,
      -1,    41,    42,    43,    44,    26,    27,    -1,    48,    49,
      50,    51,    -1,    -1,    -1,     3,    -1,     5,    -1,    -1,
      41,    42,    43,    44,    -1,    -1,    -1,    48,    49,    50,
      51,    19,    -1,    -1,    -1,    -1,    -1,    -1,    26,    27,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    41,    42,    43,    44,    -1,    -1,    -1,
      48,    49,    50,    51,     7,    -1,     9,    10,    11,    12,
      13,    14,    -1,    -1,    -1,    18,    19,    20,    21,    22,
      23,    -1,    -1,    -1,    -1,    28,    29,    30,    31,    32,
      33,    34
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     3,     5,    17,    19,    26,    27,    35,    36,    37,
      38,    39,    40,    41,    42,    43,    44,    48,    49,    50,
      51,    53,    54,    55,    56,    57,    61,    62,    64,    65,
      68,    54,    61,     3,     6,    61,    66,    54,    61,    51,
      48,    51,    67,    57,    57,    57,    57,    51,     3,     0,
      15,    16,     7,     9,    10,    11,    12,    13,    14,    18,
      19,    20,    21,    22,    23,    28,    29,    30,    31,    32,
      33,    34,    58,    59,    60,    24,     4,     4,    61,     6,
      25,     4,    66,    54,    54,    45,    46,    47,    61,    63,
      61,    61,    61,    61,    61,    61,    61,     7,    61,    61,
       4,     8,    51,     8
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (scanner, args, predicate, YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if defined YYLTYPE_IS_TRIVIAL && YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (&yylval, YYLEX_PARAM)
#else
# define YYLEX yylex (&yylval, scanner)
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value, scanner, args, predicate); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, yyscan_t scanner, argBlock args, NSPredicate **predicate)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep, scanner, args, predicate)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    yyscan_t scanner;
    argBlock args;
    NSPredicate **predicate;
#endif
{
  if (!yyvaluep)
    return;
  YYUSE (scanner);
  YYUSE (args);
  YYUSE (predicate);
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep, yyscan_t scanner, argBlock args, NSPredicate **predicate)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep, scanner, args, predicate)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
    yyscan_t scanner;
    argBlock args;
    NSPredicate **predicate;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep, scanner, args, predicate);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *bottom, yytype_int16 *top)
#else
static void
yy_stack_print (bottom, top)
    yytype_int16 *bottom;
    yytype_int16 *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, int yyrule, yyscan_t scanner, argBlock args, NSPredicate **predicate)
#else
static void
yy_reduce_print (yyvsp, yyrule, scanner, args, predicate)
    YYSTYPE *yyvsp;
    int yyrule;
    yyscan_t scanner;
    argBlock args;
    NSPredicate **predicate;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      fprintf (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       		       , scanner, args, predicate);
      fprintf (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule, scanner, args, predicate); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
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



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep, yyscan_t scanner, argBlock args, NSPredicate **predicate)
#else
static void
yydestruct (yymsg, yytype, yyvaluep, scanner, args, predicate)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
    yyscan_t scanner;
    argBlock args;
    NSPredicate **predicate;
#endif
{
  YYUSE (yyvaluep);
  YYUSE (scanner);
  YYUSE (args);
  YYUSE (predicate);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (yyscan_t scanner, argBlock args, NSPredicate **predicate);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */






/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (yyscan_t scanner, argBlock args, NSPredicate **predicate)
#else
int
yyparse (scanner, args, predicate)
    yyscan_t scanner;
    argBlock args;
    NSPredicate **predicate;
#endif
#endif
{
  /* The look-ahead symbol.  */
int yychar;

/* The semantic value of the look-ahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;

  int yystate;
  int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Look-ahead token as an internal (translated) token number.  */
  int yytoken = 0;
#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  yytype_int16 yyssa[YYINITDEPTH];
  yytype_int16 *yyss = yyssa;
  yytype_int16 *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  YYSTYPE *yyvsp;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;


  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;


	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),

		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);

#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;


      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     look-ahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to look-ahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a look-ahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid look-ahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
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
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the look-ahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;

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
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:
// #line 177 "NSPredicateParser.ym"
    { *predicate = (yyvsp[(1) - (1)].predicate); }
    break;

  case 3:
// #line 180 "NSPredicateParser.ym"
    { (yyval.predicate) = (yyvsp[(1) - (1)].predicate); }
    break;

  case 4:
// #line 181 "NSPredicateParser.ym"
    { (yyval.predicate) = (yyvsp[(1) - (1)].predicate); }
    break;

  case 5:
// #line 182 "NSPredicateParser.ym"
    { (yyval.predicate) = truePredicate; }
    break;

  case 6:
// #line 183 "NSPredicateParser.ym"
    { (yyval.predicate) = falsePredicate; }
    break;

  case 7:
// #line 184 "NSPredicateParser.ym"
    { (yyval.predicate) = (yyvsp[(2) - (3)].predicate); }
    break;

  case 8:
// #line 187 "NSPredicateParser.ym"
    { (yyval.predicate) = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:(yyvsp[(1) - (3)].predicate), (yyvsp[(3) - (3)].predicate), nil]]; }
    break;

  case 9:
// #line 188 "NSPredicateParser.ym"
    { (yyval.predicate) = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:(yyvsp[(1) - (3)].predicate), (yyvsp[(3) - (3)].predicate), nil]]; }
    break;

  case 10:
// #line 189 "NSPredicateParser.ym"
    { (yyval.predicate) = [NSCompoundPredicate notPredicateWithSubpredicate:(yyvsp[(2) - (2)].predicate)]; }
    break;

  case 11:
// #line 192 "NSPredicateParser.ym"
    { (yyval.predicate) = [NSComparisonPredicate predicateWithLeftExpression:(yyvsp[(1) - (1)].comparison).lhs rightExpression:(yyvsp[(1) - (1)].comparison).rhs modifier:NSDirectPredicateModifier type:(yyvsp[(1) - (1)].comparison).type options:(yyvsp[(1) - (1)].comparison).options]; }
    break;

  case 12:
// #line 193 "NSPredicateParser.ym"
    { (yyval.predicate) = [NSComparisonPredicate predicateWithLeftExpression:(yyvsp[(2) - (2)].comparison).lhs rightExpression:(yyvsp[(2) - (2)].comparison).rhs modifier:NSAnyPredicateModifier type:(yyvsp[(2) - (2)].comparison).type options:(yyvsp[(2) - (2)].comparison).options]; }
    break;

  case 13:
// #line 194 "NSPredicateParser.ym"
    { (yyval.predicate) = [NSComparisonPredicate predicateWithLeftExpression:(yyvsp[(2) - (2)].comparison).lhs rightExpression:(yyvsp[(2) - (2)].comparison).rhs modifier:NSAnyPredicateModifier type:(yyvsp[(2) - (2)].comparison).type options:(yyvsp[(2) - (2)].comparison).options]; }
    break;

  case 14:
// #line 195 "NSPredicateParser.ym"
    { (yyval.predicate) = [NSComparisonPredicate predicateWithLeftExpression:(yyvsp[(2) - (2)].comparison).lhs rightExpression:(yyvsp[(2) - (2)].comparison).rhs modifier:NSAllPredicateModifier type:(yyvsp[(2) - (2)].comparison).type options:(yyvsp[(2) - (2)].comparison).options]; }
    break;

  case 15:
// #line 196 "NSPredicateParser.ym"
    { (yyval.predicate) = [NSCompoundPredicate notPredicateWithSubpredicate:[NSComparisonPredicate predicateWithLeftExpression:(yyvsp[(2) - (2)].comparison).lhs rightExpression:(yyvsp[(2) - (2)].comparison).rhs modifier:NSAnyPredicateModifier type:(yyvsp[(2) - (2)].comparison).type options:(yyvsp[(2) - (2)].comparison).options]]; }
    break;

  case 16:
// #line 199 "NSPredicateParser.ym"
    { (yyval.comparison).lhs = (yyvsp[(1) - (3)].expression); (yyval.comparison).rhs = (yyvsp[(3) - (3)].expression); (yyval.comparison).type = (yyvsp[(2) - (3)].operator).type; (yyval.comparison).options = (yyvsp[(2) - (3)].operator).options; }
    break;

  case 17:
// #line 202 "NSPredicateParser.ym"
    { (yyval.operator).type = NSBetweenPredicateOperatorType; (yyval.operator).options = 0; }
    break;

  case 18:
// #line 203 "NSPredicateParser.ym"
    { (yyval.operator) = (yyvsp[(1) - (1)].operator); }
    break;

  case 19:
// #line 206 "NSPredicateParser.ym"
    { (yyval.operator).type = (yyvsp[(1) - (1)].operatorType); (yyval.operator).options = 0; }
    break;

  case 20:
// #line 207 "NSPredicateParser.ym"
    { (yyval.operator).type = (yyvsp[(1) - (4)].operatorType); (yyval.operator).options = parseComparisonOptions((yyvsp[(3) - (4)].string)); }
    break;

  case 21:
// #line 210 "NSPredicateParser.ym"
    { (yyval.operatorType) = NSEqualToPredicateOperatorType; }
    break;

  case 22:
// #line 211 "NSPredicateParser.ym"
    { (yyval.operatorType) = NSNotEqualToPredicateOperatorType; }
    break;

  case 23:
// #line 212 "NSPredicateParser.ym"
    { (yyval.operatorType) = NSLessThanPredicateOperatorType; }
    break;

  case 24:
// #line 213 "NSPredicateParser.ym"
    { (yyval.operatorType) = NSGreaterThanPredicateOperatorType; }
    break;

  case 25:
// #line 214 "NSPredicateParser.ym"
    { (yyval.operatorType) = NSLessThanOrEqualToPredicateOperatorType; }
    break;

  case 26:
// #line 215 "NSPredicateParser.ym"
    { (yyval.operatorType) = NSGreaterThanOrEqualToPredicateOperatorType; }
    break;

  case 27:
// #line 216 "NSPredicateParser.ym"
    { (yyval.operatorType) = NSContainsPredicateOperatorType; }
    break;

  case 28:
// #line 217 "NSPredicateParser.ym"
    { (yyval.operatorType) = NSInPredicateOperatorType; }
    break;

  case 29:
// #line 218 "NSPredicateParser.ym"
    { (yyval.operatorType) = NSBeginsWithPredicateOperatorType; }
    break;

  case 30:
// #line 219 "NSPredicateParser.ym"
    { (yyval.operatorType) = NSEndsWithPredicateOperatorType; }
    break;

  case 31:
// #line 220 "NSPredicateParser.ym"
    { (yyval.operatorType) = NSLikePredicateOperatorType; }
    break;

  case 32:
// #line 221 "NSPredicateParser.ym"
    { (yyval.operatorType) = NSMatchesPredicateOperatorType; }
    break;

  case 33:
// #line 224 "NSPredicateParser.ym"
    { (yyval.expression) = (yyvsp[(1) - (1)].expression); }
    break;

  case 34:
// #line 225 "NSPredicateParser.ym"
    { (yyval.expression) = [[[NSFunctionExpression alloc] initWithSelector:selectorFromIdentifier((yyvsp[(1) - (3)].string)) argumentArray:[NSArray array]] autorelease]; }
    break;

  case 35:
// #line 226 "NSPredicateParser.ym"
    { (yyval.expression) = [[[NSFunctionExpression alloc] initWithSelector:selectorFromIdentifier((yyvsp[(1) - (4)].string)) argumentArray:(yyvsp[(3) - (4)].mutableArray)] autorelease]; }
    break;

  case 36:
// #line 227 "NSPredicateParser.ym"
    { (yyval.expression) = [[[NSVariableAssignmentExpression alloc] initWithAssignmentVariable:(yyvsp[(1) - (3)].string) expression:(yyvsp[(3) - (3)].expression)] autorelease]; }
    break;

  case 37:
// #line 228 "NSPredicateParser.ym"
    { (yyval.expression) = (yyvsp[(1) - (1)].expression); }
    break;

  case 38:
// #line 229 "NSPredicateParser.ym"
    { (yyval.expression) = (yyvsp[(1) - (1)].expression); }
    break;

  case 39:
// #line 230 "NSPredicateParser.ym"
    { (yyval.expression) = (yyvsp[(2) - (3)].expression); }
    break;

  case 40:
// #line 233 "NSPredicateParser.ym"
    { (yyval.expression) = binaryFunc(raise_toPower_, (yyvsp[(1) - (3)].expression), (yyvsp[(3) - (3)].expression)); }
    break;

  case 41:
// #line 234 "NSPredicateParser.ym"
    { (yyval.expression) = binaryFunc(multiply_by_, (yyvsp[(1) - (3)].expression), (yyvsp[(3) - (3)].expression)); }
    break;

  case 42:
// #line 235 "NSPredicateParser.ym"
    { (yyval.expression) = binaryFunc(divide_by_, (yyvsp[(1) - (3)].expression), (yyvsp[(3) - (3)].expression)); }
    break;

  case 43:
// #line 236 "NSPredicateParser.ym"
    { (yyval.expression) = binaryFunc(add_to_, (yyvsp[(1) - (3)].expression), (yyvsp[(3) - (3)].expression)); }
    break;

  case 44:
// #line 237 "NSPredicateParser.ym"
    { (yyval.expression) = binaryFunc(from_subtract_, (yyvsp[(1) - (3)].expression), (yyvsp[(3) - (3)].expression)); }
    break;

  case 45:
// #line 238 "NSPredicateParser.ym"
    { (yyval.expression) = binaryFunc(from_subtract_, zeroExpression, (yyvsp[(2) - (2)].expression)); }
    break;

  case 46:
// #line 239 "NSPredicateParser.ym"
    { (yyval.expression) = binaryFunc(objectFrom_withIndex_, (yyvsp[(1) - (4)].expression), (yyvsp[(3) - (4)].expression)); }
    break;

  case 47:
// #line 242 "NSPredicateParser.ym"
    { (yyval.expression) = (yyvsp[(1) - (1)].expression); }
    break;

  case 48:
// #line 243 "NSPredicateParser.ym"
    { (yyval.expression) = firstExpression; }
    break;

  case 49:
// #line 244 "NSPredicateParser.ym"
    { (yyval.expression) = lastExpression; }
    break;

  case 50:
// #line 245 "NSPredicateParser.ym"
    { (yyval.expression) = sizeExpression; }
    break;

  case 51:
// #line 248 "NSPredicateParser.ym"
    { (yyval.expression) = [NSExpression expressionForKeyPath:(yyvsp[(1) - (1)].string)]; }
    break;

  case 52:
// #line 249 "NSPredicateParser.ym"
    { (yyval.expression) = [NSExpression expressionForKeyPath:[(yyvsp[(1) - (2)].string) stringByAppendingString:(yyvsp[(2) - (2)].string)]]; }
    break;

  case 53:
// #line 250 "NSPredicateParser.ym"
    { (yyval.expression) = concatKeypathExpressions((yyvsp[(1) - (3)].expression), (yyvsp[(3) - (3)].expression)); }
    break;

  case 54:
// #line 253 "NSPredicateParser.ym"
    { (yyval.expression) = [[[NSConstantValueExpression alloc] initWithObject:(yyvsp[(1) - (1)].string)] autorelease]; }
    break;

  case 55:
// #line 254 "NSPredicateParser.ym"
    { (yyval.expression) = [[[NSConstantValueExpression alloc] initWithObject:(yyvsp[(1) - (1)].number)] autorelease]; }
    break;

  case 56:
// #line 255 "NSPredicateParser.ym"
    { (yyval.expression) = (yyvsp[(2) - (2)].expression); }
    break;

  case 57:
// #line 256 "NSPredicateParser.ym"
    { (yyval.expression) = [[[NSVariableExpression alloc] initWithObject:(yyvsp[(1) - (1)].string)] autorelease]; }
    break;

  case 58:
// #line 257 "NSPredicateParser.ym"
    { (yyval.expression) = nullExpression; }
    break;

  case 59:
// #line 258 "NSPredicateParser.ym"
    { (yyval.expression) = yesExpression; }
    break;

  case 60:
// #line 259 "NSPredicateParser.ym"
    { (yyval.expression) = noExpression; }
    break;

  case 61:
// #line 260 "NSPredicateParser.ym"
    { (yyval.expression) = selfExpression; }
    break;

  case 62:
// #line 261 "NSPredicateParser.ym"
    { (yyval.expression) = [[[NSAggregateExpression alloc] initWithCollection:[NSArray array]] autorelease]; }
    break;

  case 63:
// #line 262 "NSPredicateParser.ym"
    { (yyval.expression) = [[[NSAggregateExpression alloc] initWithCollection:(yyvsp[(2) - (3)].mutableArray)] autorelease]; }
    break;

  case 64:
// #line 265 "NSPredicateParser.ym"
    { (yyval.mutableArray) = [NSMutableArray arrayWithObject:(yyvsp[(1) - (1)].expression)]; }
    break;

  case 65:
// #line 266 "NSPredicateParser.ym"
    { [(yyvsp[(1) - (3)].mutableArray) addObject:(yyvsp[(3) - (3)].expression)]; (yyval.mutableArray) = (yyvsp[(1) - (3)].mutableArray); }
    break;

  case 66:
// #line 269 "NSPredicateParser.ym"
    { (yyval.expression) = coerceObjectToExpression(args, (yyvsp[(1) - (1)].string)); }
    break;

  case 67:
// #line 270 "NSPredicateParser.ym"
    { (yyval.expression) = coerceObjectToExpression(args, (yyvsp[(1) - (1)].string)); }
    break;

  case 68:
// #line 273 "NSPredicateParser.ym"
    { (yyval.string) = (yyvsp[(2) - (2)].string); }
    break;


/* Line 1267 of yacc.c.  */
// #line 1970 "NSPredicateParser.tab.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;


  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (scanner, args, predicate, YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (scanner, args, predicate, yymsg);
	  }
	else
	  {
	    yyerror (scanner, args, predicate, YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse look-ahead token after an
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
		      yytoken, &yylval, scanner, args, predicate);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse look-ahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule which action triggered
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
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
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
		  yystos[yystate], yyvsp, scanner, args, predicate);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (scanner, args, predicate, YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEOF && yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval, scanner, args, predicate);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp, scanner, args, predicate);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}


// #line 275 "NSPredicateParser.ym"


#pragma clang diagnostic pop

static NSFunctionExpression *binaryFunc(SEL selector, NSExpression *lhs, NSExpression *rhs)
{
    return [[[NSFunctionExpression alloc] initWithSelector:selector argumentArray:[NSArray arrayWithObjects:lhs, rhs, nil]] autorelease];
}

static NSExpression *concatKeypathExpressions(NSExpression *lhs, NSExpression *rhs)
{
    NSString *keyPath;

    if ([lhs isKindOfClass:[NSSelfExpression class]])
    {
        keyPath = [rhs keyPath];
    }
    else
    {
        keyPath = [NSString stringWithFormat:@"%@.%@", [lhs keyPath], [rhs keyPath]];
    }

    return [NSExpression expressionForKeyPath:keyPath];
}

static SEL selectorFromIdentifier(NSString *name)
{
    static NSSet *legalNames;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        legalNames = [[NSSet alloc] initWithObjects: @"abs:", @"average:", @"ceiling:", @"count:",
                      @"exp:", @"floor:", @"ln:", @"log:", @"max:", @"median:", @"min:", @"mode:",
                      @"now:", @"random:", @"randomn:", @"sqrt:", @"stddev:", @"sum:", @"trunc:", nil];
    });

    if (![name hasSuffix:@":"])
    {
        name = [name stringByAppendingString:@":"];
    }

    if (![legalNames member:name])
    {
        [NSException raise:NSInvalidArgumentException format:@"Illegal function name '%@' when parsing expression", name];
    }

    return NSSelectorFromString(name);
}

void predicate_error(yyscan_t scanner, argBlock args, NSPredicate **predicate, const char *error)
{
    _parsePredicateError(error);
}

void _parsePredicateError(const char *error)
{
    [NSException raise:NSInvalidArgumentException format:@"Error parsing predicate format: %s", error];
}

static NSPredicate *parsePredicate(NSString *format, argBlock args)
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        truePredicate = [NSTruePredicate defaultInstance];
        falsePredicate = [NSFalsePredicate defaultInstance];

        zeroExpression = [[NSConstantValueExpression alloc] initWithObject:@0];
        nullExpression = [[NSConstantValueExpression alloc] initWithObject:[NSNull null]];
        yesExpression = [[NSConstantValueExpression alloc] initWithObject:@YES];
        noExpression = [[NSConstantValueExpression alloc] initWithObject:@NO];

        firstExpression = [[NSSymbolicExpression alloc] initWithString:@"FIRST"];
        lastExpression = [[NSSymbolicExpression alloc] initWithString:@"LAST"];
        sizeExpression = [[NSSymbolicExpression alloc] initWithString:@"SIZE"];

        selfExpression = [NSSelfExpression defaultInstance];

        add_to_ = sel_registerName("add:to:");
        from_subtract_ = sel_registerName("from:subtract:");
        multiply_by_ = sel_registerName("multiply:by:");
        divide_by_ = sel_registerName("divide:by:");
        raise_toPower_ = sel_registerName("raise:toPower:");
        objectFrom_withIndex_ = sel_registerName("objectFrom:withIndex:");
    });

    const char *formatBytes = [format UTF8String];

    yyscan_t lexer;
    YY_BUFFER_STATE state;
    _predicate_lexer_create(formatBytes, &lexer, &state);

    NSPredicate *predicate = nil;
    predicate_parse(lexer, args, &predicate);

    _predicate_lexer_destroy(lexer, state);

    return predicate;
}

static NSComparisonPredicateOptions parseComparisonOptions(NSString *optionString)
{
    optionString = [optionString lowercaseString];

    NSComparisonPredicateOptions options = 0;

    if ([optionString rangeOfString:@"c"].location != NSNotFound)
    {
        options |= NSCaseInsensitivePredicateOption;
    }
    if ([optionString rangeOfString:@"d"].location != NSNotFound)
    {
        options |= NSDiacriticInsensitivePredicateOption;
    }
    if ([optionString rangeOfString:@"n"].location != NSNotFound)
    {
        options |= NSNormalizedPredicateOption;
    }
    if ([optionString rangeOfString:@"l"].location != NSNotFound)
    {
        options |= NSLocaleSensitivePredicateOption;
    }

    return options;
}

static NSExpression *coerceObjectToExpression(argBlock args, NSString *formatType)
{
    id object = args(formatType);

    if ([formatType isEqualToString:@"@"] ||
        [formatType isEqualToString:@"d"] ||
        [formatType isEqualToString:@"f"])
    {
        return [[[NSConstantValueExpression alloc] initWithObject:object] autorelease];
    }
    if ([formatType isEqualToString:@"K"])
    {
        if (![object isNSString__])
        {
            [NSException raise:NSInvalidArgumentException format:@"Tried to substitute non-string %@ into predicate format", object];
            return nil;
        }
        return [NSExpression expressionForKeyPath:object];
    }

    [NSException raise:NSInvalidArgumentException format:@"Invalid predicate format type %@", formatType];
    return nil;
}

NSPredicate *_parsePredicateArray(NSString *format, NSArray *args)
{
    NSEnumerator *argEnumerator = [args objectEnumerator];

    return parsePredicate(format, ^NSExpression *(NSString *formatType) {
        return [argEnumerator nextObject];
    });
}

NSPredicate *_parsePredicateVarArgs(NSString *format, va_list originalArgs)
{
    __block va_list args = originalArgs;
    __block BOOL done = NO;

    return parsePredicate(format, ^NSExpression *(NSString *formatType) {
        if (done)
        {
            return nil;
        }
        id object = nil;
        if ([formatType isEqualToString:@"@"] ||
            [formatType isEqualToString:@"K"])
        {
            object = va_arg(args, id);
        }
        else if ([formatType isEqualToString:@"d"])
        {
            object = [NSNumber numberWithInt:va_arg(args, int)];
        }
        else if ([formatType isEqualToString:@"f"])
        {
            object = [NSNumber numberWithDouble:va_arg(args, double)];
        }
        if (object == nil)
        {
            done = YES;
        }
        return object;
    });
}

