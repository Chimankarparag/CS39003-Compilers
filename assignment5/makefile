all: parser

y.tab.c y.tab.h: ctype.y
	bison -y -d ctype.y

lex.yy.c: ctype.l y.tab.h
	flex ctype.l

parser: y.tab.c lex.yy.c
	gcc -o parser y.tab.c lex.yy.c

run: parser
	./parser decl.c

clean:
	rm -f parser lex.yy.c y.tab.c y.tab.h ctype.tab.c ctype.tab.h
