all:
	flex lexer.l
	bison -d parser.y
	# Since we have noyywrap enabled, we don't need to compile with -lfl
	g++ -o nutshell nutshell.cpp lex.yy.c parser.tab.c

clean:
	rm parser.tab.c parser.tab.h lex.yy.c nutshell