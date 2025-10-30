%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

// in this file the PLUS MINUS tokens were not needed but it was too late to correct

%}

ws	            [ \t]+
ows	[ \t]*
id	            [a-zA-Z_][a-zA-Z0-9_]*
num	            [+-]?[0-9]+
literalstr      [a-zA-Z]+
newline         [\n]


%x RVALUE



%%
[ \t\r]+    
<INITIAL>{id}	         {  yylval.sval = strdup(yytext);return ID;     }
<INITIAL>"="             { BEGIN RVALUE;return ASG;   }
<INITIAL>"\n"                      { BEGIN(INITIAL); return EOL; }

<RVALUE>{ws}	          { }
<RVALUE>{literalstr}     { yylval.sval = strdup(yytext);return STR;  }
<RVALUE>${id}            { yylval.sval = strdup(yytext+1);return REF;    }
<RVALUE>{num}            { yylval.ival = atoi(yytext);return NUM;   }
<RVALUE>"+"              { return PLUS; }
<RVALUE>"-"              { return MINUS; }
<RVALUE>"^"              { return XPT; }
<RVALUE>"["              { return LRANGE; }
<RVALUE>"]"              { return RRANGE; }
<RVALUE>","              { return COMMA; }
<RVALUE>"<"              { return PREFIX; }
<RVALUE>">"              { return SUFFIX; }
<RVALUE>"("              { return LPAREN; }
<RVALUE>")"              { return RPAREN; }


<*>{newline}             { BEGIN INITIAL; return EOL;   }


<*>.                    {   fprintf(stderr, "Lex warning: invalid character '%s' !! Ignored !! \n", yytext);

                        }

%%

int yywrap(){
    return 1;
}