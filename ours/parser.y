%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"

int yylex(void);
int yyerror(char *s);
int cd(char* arg);
int setAlias(char *name, char *word);
int unAlias(char *name);
int listAliases();
int setEnv(char* name, char* val);
int unsetEnv(char* name);
%}

%union {char *string;}

%start cmd_line
%token <string> BYE CD ALIAS SETENV UNSETENV UNALIAS STRING END

%%
cmd_line    :
	BYE END 		                {exit(1); return 1; }
	| CD STRING END        			{cd($2); return 1;}
	| ALIAS STRING STRING END		{setAlias($2, $3); return 1;}
	| ALIAS END						{listAliases(); return 1;}
	| UNALIAS STRING END			{unAlias($2); return 1;}
	| SETENV STRING STRING END		{setEnv($2, $3); return 1;}
	| UNSETENV STRING END			{unsetEnv($2); return 1;}

%%

int yyerror(char *s) {
  printf("%s\n",s);
  return 0;
  }

int cd(char* arg) {
	if (arg[0] != '/') { // arg is relative path
		strcat(varTable.word[0], "/");
		strcat(varTable.word[0], arg);

		if(chdir(varTable.word[0]) == 0) {
			return 1;
		}
		else {
			getcwd(cwd, sizeof(cwd));
			strcpy(varTable.word[0], cwd);
			printf("Directory not found\n");
			return 1;
		}
	}
	else { // arg is absolute path
		if(chdir(arg) == 0){
			strcpy(varTable.word[0], arg);
			return 1;
		}
		else {
			printf("Directory not found\n");
                       	return 1;
		}
	}
}

int setAlias(char *name, char *word) {
	for (int i = 0; i < aliasIndex; i++) {
		if(strcmp(name, word) == 0){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		else if(strcmp(aliasTable.name[i], name) == 0) {
			strcpy(aliasTable.word[i], word);
			return 1;
		}
	}
	strcpy(aliasTable.name[aliasIndex], name);
	strcpy(aliasTable.word[aliasIndex], word);
	aliasIndex++;

	return 1;
}