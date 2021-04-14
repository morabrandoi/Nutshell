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
int aliasFlag = 1;

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
bye                 { aliasFlag = 0; return BYE; }
cd		            { aliasFlag = 0; return CD;}
alias		        { aliasFlag = 0; return ALIAS; }
setenv              { aliasFlag = 0; return SETENV; }
unsetenv            { aliasFlag = 0; return UNSETENV; }
unalias             { aliasFlag = 0; return UNALIAS; }
"\n"		        { aliasFlag = 1; return END; }
[\"]                { BEGIN(string_condition); }
{CHAR}+             { 
                        
                        if ( aliasFlag == 1 && ifAlias(yytext) ) {
                            
                            printf("yytext: %s\n", yytext);
                            //source: https://www.cs.princeton.edu/~appel/modern/c/software/flex/flex.html
                            char *yycopy = strdup( subAliases(yytext) );
                            for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i )
                                unput( yycopy[i] );
                            free( yycopy );
                        } else {
                            printf("yytext: %s\n", yytext);
                            yylval.string = strdup(yytext);
                            aliasFlag = 0;
                            return STRING;
                        };
                    }
%%