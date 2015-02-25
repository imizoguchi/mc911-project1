%{
#include <stdio.h>

void yyerror(const char* errmsg);
int yywrap(void);
int yylex();

%}

%union{
	char *str;
	int intval;
}

%token <intval> T_DIGIT
%token <str> T_STRING
%token <void> T_NEWLINE
%type <str> cmd

%%

stmt_list:  	stmt newlines
	 | 	stmt_list stmt newlines
	 | newlines

newlines : T_NEWLINE | newlines T_NEWLINE

stmt: cmd mandatory_arg
		{ printf("reduce stmt: %s", $1); }
	| cmd optional_arg mandatory_arg
		{ printf("reduce stmt with optional: %s", $1); }

cmd:	'\\' T_STRING { printf("reduce cmd: %s", $2); $$ = $2; }

optional_arg:	'[' T_STRING ']'

mandatory_arg:	'{' T_STRING '}'

%%

void yyerror(const char* errmsg)
{
	printf("***Error: %s\n", errmsg);
}


int yywrap(void){
	return 1;
}

int main()
{
	yyparse();
	return 0;
}



