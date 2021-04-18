#include "stdbool.h"
#include <limits.h>
#define WORDS 1024
#define WORD_LENGTH 1024

struct evTable {
   char var[WORDS][WORD_LENGTH];
   char word[WORDS][WORD_LENGTH];
};

struct aTable {
	char name[WORDS][WORD_LENGTH];
	char word[WORDS][WORD_LENGTH];
};

struct commandTable {
   char commandArr[WORDS][WORD_LENGTH];
   int index;
   bool hasAmper;
};

char cwd[PATH_MAX];

struct evTable varTable;

struct aTable aliasTable;



// char anyCommand[WORDS][WORD_LENGTH];
int aliasIndex, varIndex;

int commandIndex;

char* subAliases(char* name);