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
%token <str> T_PARAGRAPH

%%

stmt_list:  	stmt ';'
	 | 	stmt_list stmt ';'

stmt: cmd mandatory_arg { printf("%d", 1); }

cmd:	'\\' T_STRING

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



