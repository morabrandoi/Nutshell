CC=/usr/bin/cc

all: 
	bison -d parser.y
	flex lexer.l
	$(CC) nutshell.c parser.tab.c lex.yy.c -o nutshell

debug: 
	bison -t -d parser.y
	flex -d lexer.l
	$(CC) nutshell.c parser.tab.c lex.yy.c -o nutshell

clean:
	rm parser.tab.c parser.tab.h lex.yy.c nutshell