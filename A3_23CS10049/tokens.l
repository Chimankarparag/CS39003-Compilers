%{

#include <stdio.h>
#include <string.h>

//terminals
#define ID 1007
#define NUM 1008
#define STR 1009
#define REF 1010

#define LPN 1011
#define RPN 1012
#define CRT 1013
#define PLUS 1014
#define ASG 1015
#define EOL 1016
#define INV 1017

//to store 
char elexe[1024];

%}

ws	            [ \t]+
id	            [a-zA-Z_][a-zA-Z0-9_]*
num	            [+-]?[0-9]+
literalstr      [a-zA-Z]+
newline         [\n]

%x RVALUE


%%

<INITIAL>{ws}	         { }

<INITIAL>{id}	         { 
                            strcpy(elexe,yytext);
                            return ID;     }

<INITIAL>"="             { BEGIN RVALUE;return ASG;   }

<RVALUE>{ws}	         { }
<RVALUE>{num}            { strcpy(elexe,yytext);return NUM;   }
<RVALUE>{literalstr}     { strcpy(elexe,yytext);return STR;  }
<RVALUE>${id}            { strcpy(elexe,yytext);return REF;    }

<RVALUE>"("	             { return LPN;   }
<RVALUE>")"	             { return RPN;   }
<RVALUE>"^"              { return CRT;   }
<RVALUE>"+"	             { return PLUS;   }


<*>{newline}             { BEGIN INITIAL; return EOL;   }


<*>.                    {   fprintf(stderr, "Lex warning: invalid character '%s' !! Ignored !! \n", yytext);

                        }

%%

int yywrap(){
    return 1;
}