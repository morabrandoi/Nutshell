%{
#include "parser.tab.h"
#include <string.h>
#include "global.h"

bool ifVar(char* var){
    for(int i = 0; i < varIndex; i++) {
        if(strcmp(varTable.var[i], var) == 0) {
            return true;
        }
    }
    return false;
}

char* subVar(char* var) {
    for(int i = 0; i < varIndex; i++) {
        if(strcmp(varTable.var[i], var) == 0) {
            return varTable.word[i];
        }
    }
    return var;
}

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

int onWordInd = 0; // 0 based indexing

%}
%array
%option noyywrap
%x string_condition
%x var_condition

CHAR            [(\\&)(\\|)(\\\\)(\\>)(\\<).A-Za-z0-9!\?*:/_-][(\\&)(\\|)(\\\\)(\\>)(\\<).A-Za-z0-9!\?*:/_-]*
ANYCHAR         [)(*&%$#@!}{`;,\.a-zA-Z0-9'/*_=~ -][)(*&%$#@!}{`;,\.a-zA-Z0-9'/*_=~ -]*
METACHAR        [<>|"\&]


%%

<string_condition>{ANYCHAR}+    { yylval.string = strdup(yytext); return STRING;}
<string_condition>[\"]          {BEGIN(INITIAL);}

<var_condition>{CHAR}+          { if ( ifVar(yytext) ) {
                                    char *yycopy = strdup( subVar(yytext) );
                                    for ( int i = strlen(subVar(yytext)) - 1; i >= 0; --i )
                                        unput( yycopy[i] );
                                    free( yycopy );
                                    } else {
                                        yylval.string = strdup(yytext);
                                        onWordInd++;
                                        return STRING;
                                    }; 
                                }
<var_condition>"}"              {BEGIN(INITIAL);}


[ ]		            { }
bye                 { yylval.string = strdup(yytext); return (onWordInd++ == 0) ? BYE : STRING; }
cd		            { yylval.string = strdup(yytext); return (onWordInd++ == 0) ? CD : STRING;}
alias		        { yylval.string = strdup(yytext); return (onWordInd++ == 0) ? ALIAS : STRING; }
setenv              { yylval.string = strdup(yytext); return (onWordInd++ == 0) ? SETENV : STRING; }
unsetenv            { yylval.string = strdup(yytext); return (onWordInd++ == 0) ? UNSETENV : STRING; }
unalias             { yylval.string = strdup(yytext); return (onWordInd++ == 0) ? UNALIAS : STRING; }
printenv            { yylval.string = strdup(yytext); return (onWordInd++ == 0) ? PRINTENV : STRING; }
[\n\r]		        { onWordInd = 0; return END; }

[\"]                { BEGIN(string_condition); }
"${"                { BEGIN(var_condition);}

"&"                 { yylval.string = strdup(yytext); return AMPER;}

{CHAR}+             {   
                           int i=0;
                           int j=0;
                            char *text = strdup(yytext);
                            while(i < strlen(text)) {                               
                                if(text[i]=='\\' && text[i+1]=='\\' && i <= strlen(text)-1) {
                                    i++;                            
                                }
                                if(text[i]=='\\') { 
                                    for(j=i; j < strlen(text); j++) {
                                        text[j] = text[j+1];
                                    } 
                                }
                                else {
                                        i++;
                                }
                            }
                             strcpy(yytext,text);
                        // onWordInd checks onl the first token is considered for alias expansion
                        // this whole block basically checks if its an alias word and expands on it if it is
                        if ( onWordInd == 0 && ifAlias(yytext) ) {
                            char *yycopy = strdup( subAliases(yytext) );
                            
                            for ( int i = strlen(subAliases(yytext)) - 1; i >= 0; --i ){
                                unput( yycopy[i] );
                            }
                            free( yycopy );
                        } else {
                            yylval.string = strdup(yytext);
                            onWordInd++;
                            return STRING;
                        };
                    }

%%