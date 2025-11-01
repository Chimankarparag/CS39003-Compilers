%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

int lineno = 0;
%}

ws	[ \t]+
num	[0-9]+
id	[a-zA-Z_][a-zA-Z0-9_]*
str	[a-zA-Z]+
ref	\${id}

%x RVALUE

%%

<*>{ws}		{ }
<INITIAL>{id}	{ yylval.str = strdup(yytext); return ID; }
<INITIAL>=	{ ++lineno; BEGIN RVALUE; return yytext[0]; }
<INITIAL>\n	{ ++lineno; return yytext[0]; }
<RVALUE>{ref}	{ yylval.str = strdup(yytext + 1); return REF; }
<RVALUE>{str}	{ yylval.str = strdup(yytext); return STR; }
<RVALUE>{num}	{ yylval.val = atoi(yytext); return NUM; }
<RVALUE>\+	{ return yytext[0]; }
<RVALUE>-	{ return yytext[0]; }
<RVALUE>\[	{ return yytext[0]; }
<RVALUE>\]	{ return yytext[0]; }
<RVALUE>>	{ return yytext[0]; }
<RVALUE><	{ return yytext[0]; }
<RVALUE>,	{ return yytext[0]; }
<RVALUE>\^	{ return yytext[0]; }
<RVALUE>\(	{ return yytext[0]; }
<RVALUE>\)	{ return yytext[0]; }
<RVALUE>\n	{ BEGIN INITIAL; return yytext[0]; }
<*>.		{ fprintf(stderr, "*** Lex error: unrecgnized character '%c'\n", yytext[0]); }

%%

int yywrap ()  { return 1; }
