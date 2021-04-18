## Division of Responsibility:

Both members worked with each other to ensure that each one was doing their parts properly and assisted each other when either needed help. Both contributed to various sections of 
the README document. Both tested various commands to ensure that the implemented features were working properly.

## Brando Mora:
Set up and created base structure for built-in commands and non-built-in commands. Responsible for developing setenv, printenv, unsetenv, cd, alias, unalias, and bye. Created the code for alias expansion. Responsible for dealing with infinite alias loop expansion. Responsible for wildcard matching. Worked on ensuring shell robustness by accounting for possible errors. Responsible for having non-built-in commands running in the background.

## Martin Tolxdorf:
Assisted in developing built-in commands and non-built-in commands. Created the code for environment variable expansion and assisted with alias expansion.
Worked on creating various tokens for the lexer including handling for metacharacters and handling of those characters being backslashed. Began working on Tilde Expansion
but was unable to complete. Worked on ensuring shell robustness by accounting for possible errors.

## Features NOT implemented
* I/O redirection
* Piping functionality

## Extra Credit Features NOT implemented
* Tilde Expansion
* File Name completion

## Features that ARE implemented
* all built-in commands (including alias loop detection)
* Alias expansion
* Environment variable expansion
* non-built-in commands (with and without arguments)
* Running non-built-in commands in the background
* Wildcard matching






