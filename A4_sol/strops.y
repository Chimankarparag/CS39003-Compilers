%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct range {
   int type;
   int rbgn;
   int rend;
} yyrange;
struct range *yyrng;

extern int lineno;
extern char *yytext;
extern int yylex();
extern FILE *yyin;

typedef struct {
   char *name;
   char *value;
} pair;
pair ST[4096];
int nstentry = 0;

char *stradd ( char *, char * );
char *strsub ( char *, char * );
char *strexp ( char *, int );
char *strrng ( char *, struct range * );
char *STget ( char * );
int STput ( char *, char * );
void prnres ( int );
void yyerror ( char * );
%}

%union {
   int val;
   char *str;
   struct range *rng;
}

%token <val> NUM
%token <str> ID REF STR

%type <val> XPNT LINE
%type <str> EXPR TERM BASE
%type <rng> RANGE

%%

PROG	: LINE '\n'
	| LINE '\n' PROG
	;

LINE	: ID '=' EXPR { $$ = STput($1,$3); prnres($$); }
	| { printf("\n"); $$ = -1; }
	;

EXPR	: EXPR '+' TERM  { $$ = stradd($1,$3); }
	| EXPR '-' TERM  { $$ = strsub($1,$3); }
	| TERM           { $$ = $1; }
	;

TERM	: TERM '^' XPNT  { $$ = strexp($1,$3); }
	| TERM '[' RANGE ']'  {  $$ = strrng($1,$3); }
	| BASE  { $$ = $1; }
	;

XPNT	: NUM  { $$ = $1; }
	;

RANGE	: NUM  { yyrng -> type = 'R'; yyrng -> rbgn = yyrng -> rend = $1; $$ = yyrng; }
	| NUM ',' NUM  { yyrng -> type = 'R'; yyrng -> rbgn = $1; yyrng -> rend = $3; $$ = yyrng; }
	| '<' NUM { yyrng -> type = 'R'; yyrng -> rbgn = 0; yyrng -> rend = $2 - 1; $$ = yyrng; }
	| '>' NUM { yyrng -> type = 'S'; yyrng -> rbgn = - $2; $$ = yyrng; }
	;

BASE	: STR		{ $$ = $1; }
	| REF		{ $$ = STget($1); }
	| '(' EXPR ')'  { $$ = $2; }
	;

%%

void yyerror ( char *msg )
{
   fprintf(stderr, "*** Error in Line %d: %s\n", lineno, msg);
   exit(1);
}

int main ( int argc, char *argv[] )
{
   if (argc > 1) yyin = (FILE *)fopen(argv[1],"r");
   yyrng = &yyrange;
   yyparse();
   fclose(stdin);
   exit(0);
}

char *stradd ( char *s1, char *s2 )
{
   char *t;
   int l1, l2;

   l1 = strlen(s1); l2 = strlen(s2);
   t = (char *)malloc((l1 + l2 + 1) * sizeof(char));
   strcpy(t,s1);
   strcpy(t+l1,s2);
   return t;
}

char *strsub ( char *s1, char *s2 )
{
   char *t;
   int l1, l2, i1, i2, j;

   l1 = strlen(s1); l2 = strlen(s2);
   t = (char *)malloc((l1+1) * sizeof(char));
   i1 = i2 = j = 0;
   while ((s1[i1]) && (s2[i2])) {
      if (s1[i1] == s2[i2]) {
         ++i1; ++i2;
      } else {
         t[j] = s1[i1];
         ++i1; ++j;
      }
   }
   while (s1[i1]) t[j++] = s1[i1++];
   t[j] = '\0';
   return t;
}

char *strexp ( char *s, int n )
{
   char *t, *p;
   int l, i;

   l = strlen(s);
   p = t = (char *)malloc((n*l+1)*sizeof(char));
   for (i=0; i<n; ++i) {
      strcpy(p,s);
      p += l;
   }
   return t;
}

char *strrng ( char *s, struct range *rng )
{
   int l, i, j;
   char *t;

   l = strlen(s);
   switch (rng -> type) {
      case 'R' : break;
      case 'S' : rng -> rbgn += l; rng -> rend = l - 1; break;
      case 'F' : rng -> rend = l - 1; break;
      default:
         fprintf(stderr, "*** Error: Invalid range\n");
         rng -> rbgn = 0; rng -> rend = -1; break;
   }
   if (rng -> rbgn < 0) rng -> rbgn = 0;
   if (rng -> rend >= l) rng -> rend = l - 1;
   if (rng -> rbgn > rng -> rend) return strdup("");
   l = rng -> rend - rng -> rbgn +  1;
   t = (char *)malloc((l + 1) * sizeof(char));
   for (i=rng->rbgn,j=0; j<l; ++i,++j) t[j] = s[i];
   t[l] = '\0';
   return t;
}

int STfind ( char *name )
{
   int i;

   for (i=0; i<nstentry; ++i)
      if (!strcmp(name,ST[i].name)) return i;
   return -1;
}

char *STget ( char *name )
{
   int i;

   i = STfind(name);
   if (i < 0) {
      fprintf(stderr, "*** Undefined string %s\n", name);
      return strdup("");
   }
   return strdup(ST[i].value);
}

int STput ( char *name, char *value )
{
   int i;

   i = STfind(name);
   if (i < 0) {
      i = nstentry;
      ++nstentry;
      ST[i].name = strdup(name);
   } else {
      free(ST[i].value);
   }
   ST[i].value = strdup(value);
   return i;
}

void prnres ( int i )
{
   printf("    Stored %s = %s\n", ST[i].name, ST[i].value);
}
