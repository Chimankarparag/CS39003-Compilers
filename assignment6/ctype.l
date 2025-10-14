%option noyywrap yylineno

%{
#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%%
[ \t\r]+               { }
\n                     { }

unsigned[ \t]+short[ \t]+int   { return USRT; }
unsigned[ \t]+short            { return USRT; }
short[ \t]+int                 { return SRT; }
short                          { return SRT; }
unsigned[ \t]+long[ \t]+int    { return ULNG; }
unsigned[ \t]+long             { return ULNG; }
long[ \t]+int                  { return LNG; }
long                           { return LNG; }
unsigned[ \t]+char             { return UCHR; }
char                           { return CHR; }
unsigned[ \t]+int              { return UINT; }
unsigned                       { return UINT; }
void                           { return VOID; }
int                            { return INT; }
float                          { return FLT; }
double                         { return DBL; }
struct                         { return STRUCT; }

"*"                            { return '*'; }
","                            { return ','; }
";"                            { return ';'; }
"["                            { return '['; }
"]"                            { return ']'; }
"{"                            { return '{'; }
"}"                            { return '}'; }

[0-9]+                         { yylval.ival = atoi(yytext); return num; }
[A-Za-z_][A-Za-z0-9_]*         { yylval.sval = strdup(yytext); return id; }

.                              { }
%%
