%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct range {
    int kind;  
    int st;    
    int end;      
};

extern FILE *yyin ;
int yylex() ;
void yyerror ( const char * ) ;

char* str_concat(const char* s, const char* t);
char* str_subtract(const char* s, const char* t);
char* str_power(const char* s, int n);
char* str_range_apply(const char* s, const struct range* r);


#define MAXVARS 2048
static char* STname[MAXVARS];
static char* STvalue[MAXVARS];
static int   STcount = 0;

static char* stringdup(const char* s){
    if(!s) return NULL;
    size_t n = strlen(s);
    char* p = (char*)malloc(n+1);
    if(!p){ fprintf(stderr,"Memory allocation failed\n"); exit(1); }
    memcpy(p, s, n+1);
    return p;
}

static int STfind(const char* name){
    for(int i=0;i<STcount;i++){
        if(strcmp(STname[i], name)==0) return i;
    }
    return -1;
}

static void STstore( const char* name, const char* value){
	int idx = STfind(name);
	if(idx<0){
		if(STcount>=MAXVARS){ fprintf(stderr,"Symbol table full\n"); exit(1); }
		// add new value 
		STname[STcount] = stringdup(name);
		STvalue[STcount] = stringdup(value);
		STcount++;

	}else{
		// update existing value 
		free(STvalue[idx]);
		STvalue[idx] = stringdup(value);
	}
	printf("    Stored %s = %s\n", name, value);

}

static char* STload( const char* name){
	int idx = STfind(name);
	if(idx<0){
		fprintf(stderr,"*** Undefined string %s \n", name);
		char* temp = malloc(1);
		temp[0]='\0';
		return temp;
	}else{
		return stringdup(STvalue[idx]);
	}
}

// in this file the PLUS MINUS tokens were not needed but it was too late to correct

%}

%union {
    char* sval;           
    int   ival;           
    struct range* rptr;   
}


%token<sval>ID
%token<sval>STR
%token<sval>REF

%token<ival>NUM
%token ASG PLUS MINUS XPT
%token LRANGE RRANGE COMMA PREFIX SUFFIX
%token LPAREN RPAREN
%token EOL

%type<sval> P L E T B
%type<rptr> R
%type<ival> X

%start P

%%

P	: L EOL 		{ }
	| L	EOL P	{ }
	;

L	: ID ASG E 	{
		STstore($1, $3);
		free($1); free($3);
		}
	;

E 	: E PLUS T { char* eval = str_concat($1, $3); free($1); free($3); $$ = eval; }
	| E MINUS T { char* eval = str_subtract($1, $3); free($1); free($3); $$ = eval; }
	| T { $$ = $1;}
	;

T	: T LRANGE R RRANGE {
		char *eval = str_range_apply($1, $3);
		free($1); free($3);
		$$ = eval;

	}
	| T XPT X 	{ char *eval = str_power($1, $3); free($1); $$ = eval; }
	| B 		{ $$ = $1; }
	;

B 	: STR 	{ $$ = $1; }
	| REF 	{ $$ = STload($1); free($1); }
	| LPAREN E RPAREN { $$ = $2; }
	;

R 	:	NUM { 
			struct range* rng = (struct range*)malloc(sizeof(struct range));
			rng->kind = 0; 
			rng->st = $1; 
			rng->end = $1; 
			$$ = rng;
		}
	|	NUM COMMA NUM {
			struct range* rng = (struct range*)malloc(sizeof(struct range));
			rng->kind = 1; 
			// many cases here ( include both st and end)
			rng->st = $1; 
			rng->end = $3; 
			$$ = rng;
		}
	|	PREFIX NUM {
			struct range* rng = (struct range*)malloc(sizeof(struct range));
			rng->kind = 2; 
			rng->st = 0; 
			// dont include end
			rng->end = $2; 
			$$ = rng;
		}
	|	SUFFIX NUM {
			struct range* rng = (struct range*)malloc(sizeof(struct range));
			rng->kind = 3; 
			// include st 
			rng->st = $2; 
			rng->end = 0; 
			$$ = rng;
		}
	;

X 	:	NUM { $$ = $1; }
	;

%%

void yyerror ( const char *msg )
{
   fprintf(stderr, "    +++ Parse error: %s\n", msg);
   exit(1);
}

int main ( int argc, char *argv[] )
{
   if (argc > 1) yyin = (FILE *)fopen(argv[1], "r");
   yyparse();
   fclose(yyin);
   exit(0);
}



char* str_concat(const char* s, const char* t){
    size_t ns = strlen(s), nt = strlen(t);
    char* out = malloc(ns+nt+1);
    memcpy(out, s, ns);
    memcpy(out+ns, t, nt);
    out[ns+nt] = '\0';
    return out;
}

char* str_subtract(const char* s, const char* t){
    size_t ns = strlen(s), nt = strlen(t);
    size_t j = 0, keep = 0;
    for(size_t i=0;i<ns;i++){
        if(j<nt && s[i]==t[j]) j++;
        else keep++;
    }
    char* out = malloc(keep+1);
    j=0; size_t w=0;
    for(size_t i=0;i<ns;i++){
        if(j<nt && s[i]==t[j]) j++;
        else out[w++]=s[i];
    }
    out[keep]='\0';
    return out;
}
char* str_power(const char* s, int n){
    if(n<=0){
		// last assignment TA told the correction : if -num then after '^' then replace it with num
		// earlier i was returning empty string 

        // char* out = malloc(1); out[0]='\0'; return out;
		n=-n;
    }
    size_t ls = strlen(s), total = ls*(size_t)n;
    char* out = malloc(total+1), *p=out;
    for(int i=0;i<n;i++){ memcpy(p,s,ls); p+=ls; }
    out[total]='\0';
    return out;
}

char* str_range_apply(const char* s, const struct range* r){
    size_t n = strlen(s);
    if(r->kind==0){
        int m = r->st;
        if(m<0 || (size_t)m>=n){ char* out=malloc(1); out[0]='\0'; return out; }
        char* out=malloc(2); out[0]=s[m]; out[1]='\0'; return out;
    }
    if(r->kind==1){
        long m=r->st, e=r->end;
        if(m<0) m=0; if(e<0) e=-1;
        if((size_t)m>=n || m>e){ char* out=malloc(1); out[0]='\0'; return out; }
        if((size_t)e>=n) e=(long)n-1;
        size_t len=(size_t)(e-m+1);
        char* out=malloc(len+1);
        memcpy(out,s+m,len); out[len]='\0'; return out;
    }
    if(r->kind==2){
        long m=r->end;
        if(m<=0){ char* out=malloc(1); out[0]='\0'; return out; }
        if((size_t)m>n) m=(long)n;
        char* out=malloc(m+1);
        memcpy(out,s,m); out[m]='\0'; return out;
    }

    long m=r->st;
    if(m<=0){ char* out=malloc(1); out[0]='\0'; return out; }
    if((size_t)m>n) m=(long)n;
    size_t start=n-(size_t)m;
    char* out=malloc(m+1);
    memcpy(out,s+start,m); out[m]='\0'; return out;
}
