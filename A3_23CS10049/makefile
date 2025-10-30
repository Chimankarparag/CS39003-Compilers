all:
	make run
	make clean
	
run:
	lex tokens.l
	g++ -std=c++17 SLRparser.cpp
	./a.out < input.txt


clean:
	rm -f a.out lex.yy.c
