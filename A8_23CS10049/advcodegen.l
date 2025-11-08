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

struct          struct
void            void
char            char
unsigned        unsigned
short           short
int             int
long            long
float           float
double          double

if              if
else            else
while           while

releq           ==
relneq          !=
rellt           <
rellte          <=
relgt           >
relgte          >=

%%

{ws}    { }



{long}{ws}{int}                             { return LNG; }
{long}                                      { return LNG; }

{struct}                                    { return STRUCT; }
{int}                                       { return INT; }
{float}                                     { return FLT; }
{double}                                    { return DBL; }

"if"                                        { return IF; }
"else"                                      { return ELSE; }
"while"                                     { return WHILE; }

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
\.                                          { return yytext[0]; }

{intconst}                                  { yylval.ival = atoi(yytext); return NUM; }   
{fltconst}                                  { yylval.fval = atof(yytext); return FLTCNST; }
{id}                                        { yylval.sval = strdup(yytext); return ID; } 


"||"                                        { return OR; }
"&&"                                        { return AND; }
"!"                                         { return NOT; }

{releq}                                     { yylval.rval = 1 ;return RELEQ; }
{relneq}                                    { yylval.rval = 2 ;return RELNEQ; }
{rellt}                                     { yylval.rval = 3 ;return RELLT; }
{rellte}                                    { yylval.rval = 4 ;return RELLTE; }
{relgt}                                     { yylval.rval = 5 ;return RELGT; } 
{relgte}                                    { yylval.rval = 6 ;return RELGTE; }




<*>.                    {   fprintf(stderr, "Lex warning: invalid character '%s' !! Ignored !! \n", yytext);

                        }

%%

int yywrap(){
    return 1;
}