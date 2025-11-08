LEX=lex
YACC=yacc
CC=gcc
CFLAGS=-g -Wall

YACC_FILE = claude
DEBUG_FILE = advcodegen_debug
LEX_FILE = advcodegen
HIT = decl

all: compile

debug: 
	$(YACC) -d $(DEBUG_FILE).y
	$(LEX) $(LEX_FILE).l
	$(CC) $(CFLAGS) y.tab.c lex.yy.c 
	./a.out $(HIT).txt

compile:
	$(YACC) -d $(YACC_FILE).y
	$(LEX) $(LEX_FILE).l
	$(CC) $(CFLAGS) y.tab.c lex.yy.c 

run: compile
	./a.out $(HIT).txt

clean:
	rm -f y.tab.c y.tab.h y.output lex.yy.c  a.out
