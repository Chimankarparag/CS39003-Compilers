%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

%}

ws	            [ \t\n\r]+
id	            [a-zA-Z_][a-zA-Z0-9_]*
intconst	    [0-9]+
fltconst        [0-9]+"."[0-9]*
newline         [\n]
dotoper         \.

struct          struct
void            void
char            char
unsigned        unsigned
short           short
int             int
long            long
float           float
double          double

%%

{ws}    { }



{long}{ws}{int}                             { return LNG; }
{long}                                      { return LNG; }

{struct}                                    { return STRUCT; }
{int}                                       { return INT; }
{float}                                     { return FLT; }
{double}                                    { return DBL; }
{dotoper}                                   { return DOT; }

[ \t\r\n]+                                  { }
,                                           { return yytext[0]; }
;                                           { return yytext[0]; }
\*                                          { return yytext[0]; }
\[                                          { return yytext[0]; }
\]                                          { return yytext[0]; }
\{                                          { return yytext[0]; }
\}                                          { return yytext[0]; }
\(                                          { return yytext[0]; }
\)                                          { return yytext[0]; }
\=                                          { return yytext[0]; }
\+                                          { return yytext[0]; }
\-                                          { return yytext[0]; }
\/                                          { return yytext[0]; }
\%                                          { return yytext[0]; }


{intconst}                                  { yylval.ival = atoi(yytext); return NUM; }   
{fltconst}                                  { yylval.fval = atof(yytext); return FLTCNST; }
{id}                                        { yylval.sval = strdup(yytext); return ID; }   

<*>.                    {   fprintf(stderr, "Lex warning: invalid character '%s' !! Ignored !! \n", yytext);

                        }

%%

int yywrap(){
    return 1;
}