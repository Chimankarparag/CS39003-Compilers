all:
	yacc -d parser.y
	lex tokens.l
	gcc y.tab.c lex.yy.c

run: all
	./a.out input.txt

clean:
	-rm -f a.out lex.yy.c y.tab.h y.tab.c
