#include "stdbool.h"
#include <limits.h>
#define WORDS 128
#define WORD_LENGTH 100

struct evTable {
   char var[128][100];
   char word[128][100];
};

struct aTable {
	char name[128][100];
	char word[128][100];
};

struct commandTable {
   char commandArr[128][100];
   int index;
};

char cwd[PATH_MAX];

struct evTable varTable;

struct aTable aliasTable;



// char anyCommand[WORDS][WORD_LENGTH];
int aliasIndex, varIndex;

char* subAliases(char* name);