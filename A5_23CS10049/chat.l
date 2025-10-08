%{
#include "y.tab.h"
#include <string.h>
#include <stdlib.h>

extern int yylval;
%}

%%

"unsigned"[ \t\n]+ "short"[ \t\n]+ "int"    { return USRT; }
"unsigned"[ \t\n]+ "short"                 { return USRT; }
"short"[ \t\n]+ "int"                      { return SRT; }
"short"                                     { return SRT; }
"unsigned"[ \t\n]+ "long"[ \t\n]+ "int"     { return ULNG; }
"unsigned"[ \t\n]+ "long"                   { return ULNG; }
"long"[ \t\n]+ "int"                        { return LNG; }
"long"                                      { return LNG; }
"unsigned"[ \t\n]+ "int"                    { return UINT; }
"unsigned"                                  { return UINT; }

"void"                                      { return VOID; }
"unsigned"[ \t\n]+ "char"                   { return UCHR; }
"char"                                      { return CHR; }
"int"                                       { return INT; }
"float"                                     { return FLT; }
"double"                                    { return DBL; }

[ \t\r\n]+                                  { /* ignore whitespace */ }
","                                         { return ','; }
";"                                         { return ';'; }
"*"                                         { return '*'; }
"["                                         { return '['; }
"]"                                         { return ']'; }

[0-9]+                                      {
                                              yylval = atoi(yytext);
                                              return NUM;
                                            }

[A-Za-z_][A-Za-z0-9_]*                      {
                                              yylval = (int) strdup(yytext);
                                              return ID;
                                            }

.                                           { /* ignore unexpected chars */ }

%%
