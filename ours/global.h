#pragma once

#include <string>
#include <iostream>


int cd(std::string* word);
int bye();
int alias();
int setenv();
int printenv();
int unsetenv();
const char* getPATH();
const char* getHOME();
void yyerror(const char* e);
