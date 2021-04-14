CC=/usr/bin/cc

all:  bison-config flex-config nutshell

debug: 
	bison -t -d parser.y
	flex -d lexer.l
	$(CC) nutshell.c parser.tab.c lex.yy.c -o nutshell

bison-config:
	bison -d parser.y

flex-config:
	flex lexer.l

nutshell: 
	$(CC) nutshell.c parser.tab.c lex.yy.c -o nutshell

clean:
	rm parser.tab.c parser.tab.h lex.yy.c nutshell