%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "global.h"

int yylex(void);
int yyerror(char *s);
int cd(char* arg);
int setAlias(char *name, char *word); // implemented. Needs to check for loops of arbitrary size
int unAlias(char *name); 
int listAliases();
int setEnv(char* name, char* val);
int unsetEnv(char* name);

%}

%union {char *string;}
%define parse.error verbose
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
	| END 							{return 1;}
	;
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
	// check if alias leads to itself
	if (strcmp(name, word) == 0){
		printf("Error, expansion of \"%s\" would create a loop.\n", name);
		return 1;
	}
	
	for (int i = 0; i < aliasIndex; i++) {	
		// checks if already in list I think
		if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
			printf("Error, expansion of \"%s\" would create a loop.\n", name);
			return 1;
		}
		// overwrites existing alias for that same name
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

int listAliases(){
	if (aliasIndex == 0) {
		printf("No aliases saved\n");
		return 1;
	}

	printf("Alias : Expansion\n");
	printf("-----------------\n");
	for (int i = 0; i < aliasIndex; i++) {
		printf("%s : %s\n", aliasTable.name[i], aliasTable.word[i]);
	}

	return 1;
}

int unAlias(char *name){
	int removeIndex = -1;
	// find index to remove
	for (int i = 0; i < aliasIndex; i++) {
		printf("check1\n");
		
		if (strcmp(aliasTable.name[i], name) == 0){
			printf("check2\n");
			removeIndex = i;
			printf("check2.1\n");
			break;
		}
	}
	printf("check2.2\n");
	
	// if no index was found, return no such alias exists
	if (removeIndex == -1){
		printf("tewstae\n");
		printf("Error, alias wif name \"%s\" does not exist.\n", name);
		return 1;
	}

	printf("check3\n");
	// delete strings at remove
	strcpy(aliasTable.name[removeIndex], "");
	strcpy(aliasTable.word[removeIndex], "");

	// check if we can fell gap we just created
	int lastIndex = aliasIndex - 1;
	if ((removeIndex != lastIndex) && lastIndex > 0){
		
		// copy stuff at end into gap
		strcpy(aliasTable.name[removeIndex], aliasTable.name[lastIndex]);
		printf("check3.1\n");
		strcpy(aliasTable.word[removeIndex], aliasTable.word[lastIndex]);	

		// free old slot at end
		strcpy(aliasTable.name[lastIndex], "");
		printf("check3.3\n");
		strcpy(aliasTable.word[lastIndex], "");
	}
	
	printf("check3.4\n");
	aliasIndex--;

	return 1;
}

int setEnv(char* name, char* val){
	return 1;
}

int unsetEnv(char* name){
	return 1;
}
