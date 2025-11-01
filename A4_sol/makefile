compile:
	yacc -d strops.y
	lex strops.l
	gcc y.tab.c lex.yy.c

run: compile
	./a.out input.txt

clean:
	-rm -f a.out lex.yy.c y.tab.c y.tab.h
