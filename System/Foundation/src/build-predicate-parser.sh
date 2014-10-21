#!/bin/sh

yacc NSPredicateParser.ym
lex NSPredicateLexer.lm
sed -i '' 's/^#line/\/\/ &/' NSPredicateLexer.m NSPredicateParser.tab.c
