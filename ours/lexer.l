%{
#include "parser.tab.h"
#include <string.h>
#include "global.h"

char* subAliases(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return aliasTable.word[i];
        }
    }
    return name;
}
bool ifAlias(char* name){
    for (int i = 0; i < aliasIndex; i++) {
        if(strcmp(aliasTable.name[i], name) == 0) {
            return true;
        }
    }
    return false;
}
%}
%array
%option noyywrap
%x string_condition

CHAR            [.A-Za-z0-9!\/_-][.A-Za-z0-9!\/_-]*
ANYCHAR            [)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -][)(*&%$#@!`;,\.a-zA-Z0-9'/*_=~ -]*

%%

<string_condition>{ANYCHAR}+     { yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]          {BEGIN(INITIAL);}

[ ]		            { }
bye                 { return BYE; }
cd		            { return CD;}
alias		        { return ALIAS; }
SETENV              { return SETENV; }
UNSETENV            { return UNSETENV; }
UNALIAS             { return UNALIAS; }
"\n"		        { return END; }
[\"]                 { BEGIN(string_condition); }
{CHAR}+              {if(ifAlias(yytext)) {
                        printf("yytext: %s\n", yytext);
                        //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                           char *yycopy = strdup( subAliases(yytext) );
                           for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
                               unput( yycopy[i] );
                           free( yycopy );
                    } else {
                        printf("yytext: %s\n", yytext);
                        yylval.string = strdup(yytext);
                        return STRING;
                    };
                     }
%%