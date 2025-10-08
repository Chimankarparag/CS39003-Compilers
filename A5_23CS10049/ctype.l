%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

%}

ws	            [ \t\n\r]+
id	            [a-zA-Z_][a-zA-Z0-9_]*
num	            [0-9]+
newline         [\n]
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


{unsigned}{ws}{short}{ws}{int}              { return USRT; }
{unsigned}{ws}{short}                       { return USRT; }
{short}{ws}{int}                            { return SRT; }
{short}                                     { return SRT; }
{unsigned}{ws}{long}{ws}{int}               { return ULNG; }
{unsigned}{ws}{long}                        { return ULNG; }
{long}{ws}{int}                             { return LNG; }
{long}                                      { return LNG; }
{unsigned}{ws}{int}                         { return UINT; }
{unsigned}                                  { return UINT; }

{void}                                      { return VOID; }
{unsigned}{ws}{char}                        { return UCHR; }
{char}                                      { return CHR; }
{int}                                       { return INT; }
{float}                                     { return FLT; }
{double}                                    { return DBL; }

[ \t\r\n]+                                  { }
,                                           { return yytext[0]; }
;                                           { return yytext[0]; }
\*                                          { return yytext[0]; }
\[                                          { return yytext[0]; }
\]                                          { return yytext[0]; }

{num}                                       { yylval.ival = atoi(yytext); return NUM; }   
{id}                                        { yylval.sval = strdup(yytext); return ID; }   

<*>.                    {   fprintf(stderr, "Lex warning: invalid character '%s' !! Ignored !! \n", yytext);

                        }

%%

int yywrap(){
    return 1;
}