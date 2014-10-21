/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

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




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 66 "NSPredicateParser.ym"
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
/* Line 1529 of yacc.c.  */
#line 171 "NSPredicateParser.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



