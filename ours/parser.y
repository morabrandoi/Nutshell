%{
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <dirent.h> // for directory reading
#include "global.h"

int cd(char* arg);
int setAlias(char *name, char *word); // implemented. Needs to check for loops of arbitrary size
int unAlias(char *name); 
int listAliases();
int setEnv(char* var, char* word);
int unsetEnv(char* name);
int printEnv();

int yylex(void);
int yyerror(const char *s);
int nonBuiltIn(struct commandTable* cmd);
struct commandTable* initCommand();
char* const* copyCommandForExec(char sample[WORDS][WORD_LENGTH], int len);

%}

%union {char *string; struct commandTable* command;}
%type<command> nonBuiltIn
%define parse.error verbose
%start cmd_line
%token <string> BYE CD ALIAS SETENV UNSETENV PRINTENV UNALIAS STRING END

%%
cmd_line    :
	BYE END 		                {exit(1); return 1; }
	| CD STRING END        			{cd($2); return 1;}
	| ALIAS STRING STRING END		{setAlias($2, $3); return 1;}
	| ALIAS END						{listAliases(); return 1;}
	| UNALIAS STRING END			{unAlias($2); return 1;}
	| SETENV STRING STRING END		{setEnv($2, $3); return 1;}
	| PRINTENV END					{printEnv(); return 1;}
	| UNSETENV STRING END			{unsetEnv($2); return 1;}
	| nonBuiltIn END				{nonBuiltIn($1); return 1;}
	| END 							{return 1;}
	
	;

nonBuiltIn :
	STRING							{ $$ = initCommand(); strcpy($$->commandArr[$$->index++], yylval.string); }
	| nonBuiltIn STRING	            { strcpy($$->commandArr[$$->index++], yylval.string); }
	;
%%

int yyerror(const char *s) {
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
	// tests for trivial self loop
	if (strcmp(name, word) == 0){
		printf("Error, expansion of \"%s\" would create a loop.\n", name);
		return 1;
	}
	
	// check for arbitrary alias loop
	char* history[WORDS];
	int hInd = 0;
	history[hInd] = name;
	history[++hInd] = word;
	while (true){
		char* curName = history[hInd];
		bool madeJumpToNext = false;
		// search through aliasTable and go to next word
		for (int i = 0; i < aliasIndex; i++) {	
			// if current matches table name
			if( (strcmp(aliasTable.name[i], curName) == 0) ){
				madeJumpToNext = true;
				char* newName = aliasTable.word[i];
				// check if it already exists in history
				for (int j = 0; j <= hInd; j++){
					// infinite loop detected
					if (strcmp(history[j], newName) == 0){
						printf("Error, expansion of \"%s\" would create a loop.\n", name);
						return 1;
					}
				}
				history[++hInd] = newName;
				break;
			}
		}

		// Done searching since nowhere to go
		if (madeJumpToNext == false){
			break;
		}
	}
	
	for (int i = 0; i < aliasIndex; i++) {	
		// checks if already in list I think
		if((strcmp(aliasTable.name[i], name) == 0) && (strcmp(aliasTable.word[i], word) == 0)){
			printf("Error, this exact alias already exists.\n");
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

	for (int i = 0; i < aliasIndex; i++) {
		printf("%s=%s\n", aliasTable.name[i], aliasTable.word[i]);
	}

	return 1;
}

int unAlias(char *name){
	int removeIndex = -1;
	// find index to remove
	for (int i = 0; i < aliasIndex; i++) {
		
		if (strcmp(aliasTable.name[i], name) == 0){
			removeIndex = i;
			break;
		}
	}
	
	// if no index was found, return no such alias exists
	if (removeIndex == -1){
		printf("Error, alias with name \"%s\" does not exist.\n", name);
		return 1;
	}

	// delete strings at remove
	strcpy(aliasTable.name[removeIndex], "");
	strcpy(aliasTable.word[removeIndex], "");

	// check if we can fell gap we just created
	int lastIndex = aliasIndex - 1;
	if ((removeIndex != lastIndex) && lastIndex > 0){
		
		// copy stuff at end into gap
		strcpy(aliasTable.name[removeIndex], aliasTable.name[lastIndex]);
		strcpy(aliasTable.word[removeIndex], aliasTable.word[lastIndex]);	

		// free old slot at end
		strcpy(aliasTable.name[lastIndex], "");
		strcpy(aliasTable.word[lastIndex], "");
	}
	aliasIndex--;

	return 1;
}

int setEnv(char* var, char* word){
	for (int i = 0; i < varIndex; i++) {	
		// checks if already in table
		if((strcmp(varTable.var[i], var) == 0) && (strcmp(varTable.word[i], word) == 0)){
			printf("Error, this variable : value pair \"%s : %s\" already in env.\n", var, word);
			return 1;
		}
		// overwrites existing alias for that same name
		else if(strcmp(varTable.var[i], var) == 0) {
			strcpy(varTable.word[i], word);
			return 1;
		}
	}
	strcpy(varTable.var[varIndex], var);
	strcpy(varTable.word[varIndex], word);
	varIndex++;

	return 1;
}

int unsetEnv(char* var){
	int removeIndex = -1;
	// find index to remove
	for (int i = 0; i < varIndex; i++) {
		
		if (strcmp(varTable.var[i], var) == 0){
			removeIndex = i;
			break;
		}
	}

	// if no index was found, return no such alias exists
	if (removeIndex == -1){
		printf("Error, variable with name \"%s\" does not exist.\n", var);
		return 1;
	}

	// delete strings at remove
	strcpy(varTable.var[removeIndex], "");
	strcpy(varTable.word[removeIndex], "");

	// check if we can fill gap we just created
	int lastIndex = varIndex - 1;
	if ((removeIndex != lastIndex) && lastIndex > 0){
		
		// copy stuff at end into gap
		strcpy(varTable.var[removeIndex], varTable.var[lastIndex]);
		strcpy(varTable.word[removeIndex], varTable.word[lastIndex]);	

		// free old slot at end
		strcpy(varTable.var[lastIndex], "");
		strcpy(varTable.var[lastIndex], "");
	}
	varIndex--;

	return 1;
}

int printEnv(){
	if (varIndex == 0) {
		printf("No env vars saved\n");
		return 1;
	}

	for (int i = 0; i < varIndex; i++) {
		printf("%s=%s\n", varTable.var[i], varTable.word[i]);
	}

	return 1;
}

struct commandTable* initCommand(){
	struct commandTable* cur = malloc(sizeof(struct commandTable)); 
	cur->index = 0;
	return cur;
	


}

int nonBuiltIn(struct commandTable* cmd){
	char* execPath = malloc(WORD_LENGTH*sizeof(char));
	bool startsWithSlash;
	bool lastAmpersandThere;

	// Printing command for validity checking. Comment out before submitting
	// int i;
	// printf("\nPRINTING WHOLE COMMAND\n");
	// for (i = 0; i < cmd->index; i++){
	// 	printf("%s ", cmd->commandArr[i]);
	// 	printf("\n\n");
	// }

	startsWithSlash = (cmd->commandArr[0][0] == '/');
	lastAmpersandThere = (strcmp(cmd->commandArr[cmd->index - 1], "&") == 0);
	// printf("is last amper there %d", lastAmpersandThere);

	// looping over path 
	char* curPath = malloc(WORD_LENGTH*sizeof(char));
	char curChar = '0';
	int pathInd = 0;
	int curInd = 0; 
	bool foundExecutable = false;
	while (!foundExecutable && curChar != 0){
		// if command starts with / replace currentPath with command
		if ( startsWithSlash ){
			strcpy(curPath, cmd->commandArr[0]);
			
			if ( access(curPath, X_OK) == 0)
			{
				foundExecutable = true;
				// printf("found a good one at %s\n", curPath);
				strcpy(execPath, curPath);
				break;
			}
			else{
				// printf("Executable could not be found at %s\n", curPath);
				break;
			}

		}


		// remove single leter and add it to curPath string
		curChar = varTable.word[3][pathInd];	
		
		// reached end of currentPath or end of whole PATH
		bool atLastCharInPath = (pathInd == strlen(varTable.word[3]) - 1);
		bool atSemiColon = curChar == ':';
		if ( atSemiColon || atLastCharInPath ){
			// end of PATH is special case. need to make sure i'm adding last char
			if (atLastCharInPath)
				curPath[curInd++] = curChar;

			// check if curPath is dot, in which case replace it with current directory
			if ( strcmp(curPath, ".") == 0)
				strcpy(curPath, varTable.word[0]);

			

			// printf("Checking: %s\n", curPath);
			// look for things in this path

			struct dirent *dirEntry;  // Pointer for directory ENTRY			
			DIR *dir = opendir(curPath); // pointer of DIR type. 
			if (dir == NULL)  // opendir returns NULL if couldn't open directory
			{
				// printf("Could not open directory %s\n\n", curPath);
			}
			else{
				// going through files of dir. looking for executable
				while ( (dirEntry = readdir(dir)) != NULL){
					// we don't care about entries . and ..
					if (!strcmp (dirEntry->d_name, "."))
						continue;
					if (!strcmp (dirEntry->d_name, ".."))    
						continue;
					
					// checking if command name is even a match. skip if not.
					bool correctCommand = strcmp(cmd->commandArr[0], dirEntry->d_name) == 0;
					if (!correctCommand)
						continue;
				
					// constructing full path
					char fullPath[WORD_LENGTH];
					strcpy(fullPath, curPath);
					strcat(fullPath, "/");
					strcat(fullPath, dirEntry->d_name);

					// checking if file exists and is executable
					if ( access(fullPath, X_OK) == 0)
					{
						foundExecutable = true;
						// printf("found a good one at %s\n", fullPath);
						strcpy(execPath, fullPath);
						break;
					}
				}
				closedir(dir);    
			}
			
			// reset curPath
			free(curPath);
			curPath = malloc(WORD_LENGTH*sizeof(char));

			// move to next letter
			curInd = 0;
			pathInd++;
		}
		// adding letter to curPath and incrementing indeces
		else{
			// replacing tilde at beginning of path with HOME path
			if (curInd == 0 && curChar=='~'){
				char* home = varTable.word[1];
				strcpy(curPath, home);

				curInd += strlen(home);
				pathInd++;
				continue;
			}

			curPath[curInd] = curChar;
			curInd++;
			pathInd++;
		}
	}
	free(curPath);
	
	if (foundExecutable){
		// execute process based on execPath
		// printf("about to execute thing at %s\n", execPath);

		pid_t pid = fork();

		if (pid == -1)
		{
			// error, failed to fork()
		} 
		else if (pid > 0)
		{
			int status;
			waitpid(pid, &status, 0);
		}
		else 
		{
			// we are the child
			char* const* goodFormArgs = copyCommandForExec(cmd->commandArr, cmd->index);
			execv(execPath, goodFormArgs);
			_exit(EXIT_FAILURE);   // exec never returns
		}
	}
	else{
		printf("Command not found: %s\n",  cmd->commandArr[0]);
	}

	return 1;
}

char* const* copyCommandForExec(char sample[WORDS][WORD_LENGTH], int len){
	char** answer = malloc(WORDS * sizeof(char*));
	int i;
	for (i = 0; i < len; i++){
		answer[i] = malloc(WORD_LENGTH*sizeof(char));
		answer[i] = sample[i];
	}
	answer[len] = NULL;
	return answer;
}