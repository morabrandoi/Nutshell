%{
#include <stdio.h>
#include <string>
#include "global.h"

int yylex(); // Defined in lex.yy.c

int yyparse(); // Need this definition so that yyerror can call it

void yyerror(const char* e) {
	printf("Errork: %s\n", e);

    yyparse();
	// We'll have to call yyparse() again to restart parsing.
}
%}

%code requires {
    #include <string>
    #include "global.h"
}
%define parse.error verbose
%define api.value.type union

%token <std::string*> BYE CD ALIAS SETENV PRINTENV UNSETENV END
%token <std::string*> WORD DOT DOTDOT TILDE
%token <std::string*> LANGLE RANGLE PIPE DUBQUOTE BACKSLASH AMPER

%%

cmd_line:
    BYE END       { bye(); return 1; }
    | CD WORD END     { cd($1); return 1; };
    | ALIAS END     { alias(); return 1; }
    | SETENV END    { setenv(); return 1; }
    | PRINTENV END  { printenv(); return 1; }
    | UNSETENV END  { unsetenv(); return 1; }
    | END           { return 1;};

