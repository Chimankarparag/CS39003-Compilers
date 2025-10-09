LEX=lex
YACC=yacc
CC=gcc
CFLAGS=-g -Wall


FILE = ctype

all: compile

compile:
	$(YACC) -d $(FILE).y
	$(LEX) ctype.l
	$(CC) $(CFLAGS) y.tab.c lex.yy.c 

run: compile
	./a.out decl.c

clean:
	rm -f y.tab.c y.tab.h y.output lex.yy.c  a.out
